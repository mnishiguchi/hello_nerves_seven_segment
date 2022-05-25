defmodule HelloNervesSevenSegment.DisplayServer do
  @moduledoc false

  use GenServer

  alias HelloNervesSevenSegment.Display

  @inverval_ms 5
  @default_characters "1234"

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def set_characters(characters) do
    GenServer.call(__MODULE__, {:set_characters, characters})
  end

  def set_brightness(brightness) when brightness in 0x000..0xFFF do
    GenServer.call(__MODULE__, {:set_brightness, brightness})
  end

  @impl GenServer
  def init(opts) do
    env = Application.get_all_env(:hello_nerves_seven_segment)

    characters = opts[:characters] || env[:initial_characters] || @default_characters
    spi_bus_name = opts[:spi_bus_name] || env[:spi_bus_name]
    gpio_pin1 = opts[:gpio_pin1] || env[:gpio_pin1]
    gpio_pin2 = opts[:gpio_pin2] || env[:gpio_pin2]
    gpio_pin3 = opts[:gpio_pin3] || env[:gpio_pin3]
    gpio_pin4 = opts[:gpio_pin4] || env[:gpio_pin4]
    brightness = opts[:brightness] || env[:brightness]

    {:ok, spi} = spi_mod().open(spi_bus_name)
    {:ok, gpio1} = gpio_mod().open(gpio_pin1, :output)
    {:ok, gpio2} = gpio_mod().open(gpio_pin2, :output)
    {:ok, gpio3} = gpio_mod().open(gpio_pin3, :output)
    {:ok, gpio4} = gpio_mod().open(gpio_pin4, :output)

    state = %{
      brightness: brightness,
      spi: spi,
      gpio: {gpio1, gpio2, gpio3, gpio4},
      characters: normalize_characters(characters),
      index: 0
    }

    {:ok, state, {:continue, :start_ticking}}
  end

  @impl GenServer
  def handle_continue(:start_ticking, state) do
    send(self(), :tick)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    Display.new(
      brightness: state.brightness,
      spi: state.spi,
      gpio: state.gpio |> elem(state.index),
      on_time_ms: @inverval_ms
    )
    |> Display.show_character(state.characters |> elem(state.index))

    send(self(), :tick)

    {:noreply, %{state | index: next_index(state)}}
  end

  @impl GenServer
  def handle_call({:set_characters, characters}, _from, state) do
    {:reply, :ok, %{state | characters: normalize_characters(characters)}}
  end

  @impl GenServer
  def handle_call({:set_brightness, brightness}, _from, state) do
    {:reply, :ok, %{state | brightness: brightness}}
  end

  defp next_index(%{index: 0}), do: 1
  defp next_index(%{index: 1}), do: 2
  defp next_index(%{index: 2}), do: 3
  defp next_index(%{index: 3}), do: 0

  defp normalize_characters(x) when is_list(x), do: List.to_tuple(x)
  defp normalize_characters(x) when tuple_size(x) == 4, do: x
  defp normalize_characters(<<a::utf8, b::utf8, c::utf8, d::utf8>>), do: {[a], [b], [c], [d]}
  defp normalize_characters(_), do: raise("unsupported characters")

  defp spi_mod(), do: Application.fetch_env!(:hello_nerves_seven_segment, :spi_mod)
  defp gpio_mod(), do: Application.fetch_env!(:hello_nerves_seven_segment, :gpio_mod)
end
