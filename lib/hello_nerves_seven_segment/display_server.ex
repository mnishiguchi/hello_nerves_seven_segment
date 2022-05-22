defmodule HelloNervesSevenSegment.DisplayServer do
  @moduledoc """
  ## Examples

  ```
  alias HelloNervesSevenSegment.DisplayServer

  DisplayServer.start_link
  DisplayServer.stop
  ```
  """

  use GenServer

  alias HelloNervesSevenSegment.Core

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def set_characters(characters) when is_tuple(characters) and tuple_size(characters) == 4 do
    GenServer.call(__MODULE__, {:set_characters, characters})
  end

  @impl GenServer
  def init(opts) do
    characters = opts[:characters] || {'1', '2', '3', '4'}
    spi_bus_name = opts[:spi_bus_name] || "spidev0.0"
    gpio_pin1 = opts[:gpio_pin1] || 6
    gpio_pin2 = opts[:gpio_pin2] || 13
    gpio_pin3 = opts[:gpio_pin3] || 19
    gpio_pin4 = opts[:gpio_pin4] || 26

    {:ok, spi} = Circuits.SPI.open(spi_bus_name)
    {:ok, gpio1} = Circuits.GPIO.open(gpio_pin1, :output)
    {:ok, gpio2} = Circuits.GPIO.open(gpio_pin2, :output)
    {:ok, gpio3} = Circuits.GPIO.open(gpio_pin3, :output)
    {:ok, gpio4} = Circuits.GPIO.open(gpio_pin4, :output)

    state = %{
      spi: spi,
      gpio: {gpio1, gpio2, gpio3, gpio4},
      characters: characters,
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
    Core.show_digits(
      spi: state.spi,
      gpio: state.gpio |> elem(state.index),
      character: state.characters |> elem(state.index),
      on_time_ms: 5
    )

    send(self(), :tick)

    {:noreply, %{state | index: next_index(state)}}
  end

  @impl GenServer
  def handle_call({:set_characters, characters}, _from, state) do
    state = %{state | characters: characters}

    {:reply, :ok, state}
  end

  defp next_index(%{index: 0}), do: 1
  defp next_index(%{index: 1}), do: 2
  defp next_index(%{index: 2}), do: 3
  defp next_index(%{index: 3}), do: 0
end
