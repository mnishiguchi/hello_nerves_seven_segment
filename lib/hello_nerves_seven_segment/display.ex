defmodule HelloNervesSevenSegment.Display do
  @moduledoc false

  alias HelloNervesSevenSegment.TLC5947Cache

  defstruct spi: nil,
            gpio: {nil, nil, nil, nil},
            on_time_ms: 5,
            brightness: 0x111

  def new(opts) do
    spi = Access.fetch!(opts, :spi)
    gpio = Access.fetch!(opts, :gpio)
    on_time_ms = opts[:on_time_ms] || 5
    brightness = opts[:brightness] || 0x111

    %__MODULE__{
      spi: spi,
      gpio: gpio,
      on_time_ms: on_time_ms,
      brightness: brightness
    }
  end

  @doc """
  Shows a specified character on the display.
  """
  def show_character(%__MODULE__{} = display, character) do
    params = %{brightness: display.brightness, character: character}
    tlc5947 = TLC5947Cache.get_or_insert_by(params, &build_tls5947/1)

    spi_mod().transfer(display.spi, tlc5947.data)
    gpio_mod().write(display.gpio, 1)
    Process.sleep(display.on_time_ms)
    gpio_mod().write(display.gpio, 0)
    :ok
  end

  defp build_tls5947(opts) do
    case brightness = opts[:brightness] do
      0 ->
        TLC5947.new(brightness: 0)

      _ ->
        bits = SevenSegment.new(opts) |> seven_segment_to_bits()
        TLC5947.new(bits: bits, brightness: brightness)
    end
  end

  defp seven_segment_to_bits(seven_segment) do
    0..23
    |> Enum.map(fn tlc5947_channel ->
      seven_segment_pin = seven_segment_pin(tlc5947_channel)
      seven_segment.pgfedcba[seven_segment_pin] || 0
    end)
  end

  defp seven_segment_pin(tlc5947_channel) when is_integer(tlc5947_channel) do
    Application.get_env(:hello_nerves_seven_segment, :tlc5947_channel_to_seven_segment_pin, [])
    |> Enum.into(%{})
    |> Access.get(tlc5947_channel, :ignore)
  end

  defp spi_mod(), do: Application.fetch_env!(:hello_nerves_seven_segment, :spi_mod)
  defp gpio_mod(), do: Application.fetch_env!(:hello_nerves_seven_segment, :gpio_mod)
end
