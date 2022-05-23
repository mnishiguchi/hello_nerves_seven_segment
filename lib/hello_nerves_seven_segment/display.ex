defmodule HelloNervesSevenSegment.Display do
  @moduledoc false

  alias HelloNervesSevenSegment.TLC5947Cache

  def show_digits(opts) do
    spi = Access.fetch!(opts, :spi)
    gpio = Access.fetch!(opts, :gpio)
    character = Access.fetch!(opts, :character)
    on_time_ms = Access.fetch!(opts, :on_time_ms)
    brightness = opts[:brightness] || 0xFFF

    transfer(spi: spi, brightness: brightness, character: character)
    Circuits.GPIO.write(gpio, 1)
    Process.sleep(on_time_ms)
    Circuits.GPIO.write(gpio, 0)
  end

  def transfer(opts) do
    spi = Access.fetch!(opts, :spi)
    tlc5947 = TLC5947Cache.get_or_insert_by(opts, &build_tls5947/1)

    Circuits.SPI.transfer(spi, tlc5947.data)
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
end
