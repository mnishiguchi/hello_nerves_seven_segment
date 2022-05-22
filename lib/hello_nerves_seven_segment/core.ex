defmodule HelloNervesSevenSegment.Core do
  @moduledoc """
  The core business logic of this project.

  ## Examples

  ```
  alias HelloNervesSevenSegment.Core

  {:ok, spi} = Circuits.SPI.open("spidev0.0")

  {:ok, digit1} = Circuits.GPIO.open(6, :output)
  {:ok, digit2} = Circuits.GPIO.open(13, :output)
  {:ok, digit3} = Circuits.GPIO.open(19, :output)
  {:ok, digit4} = Circuits.GPIO.open(26, :output)

  test_fn = fn ->
    for _ <- 0..999,
        {character, gpio} <- [{'1', digit2}, {'0', digit3}, {'0', digit4}] do
      Circuits.GPIO.write(gpio, 1)
      Core.transfer(spi: spi, brightness: 0xFFF, character: character)
      Process.sleep(1)
      Core.transfer(spi: spi, brightness: 0x000)
      Circuits.GPIO.write(gpio, 0)
    end
  end

  test_fn.()

  ```
  """

  alias HelloNervesSevenSegment.TLC5947Cache

  @supported_characters [?0..?9, ?A..?F] |> Enum.concat() |> Enum.map(&[&1])

  @tlc5947_channel_to_seven_segment_pin %{
    0 => :e,
    1 => :d,
    2 => :p,
    3 => :c,
    4 => :g,
    6 => :b,
    9 => :f,
    10 => :a
  }

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

  @doc """
  A list of the characters that this project currently supports.

  ## Examples

      iex> supported_characters()
      ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']

  """
  def supported_characters, do: @supported_characters

  @doc """
  Map a SevenSegment struct to bits. The list position corresponds to the
  TLC5947 channels.

  ## Examples

      iex> SevenSegment.new(character: 'F') |> seven_segment_to_bits()
      [1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  """
  def seven_segment_to_bits(seven_segment) do
    0..23
    |> Enum.map(fn ch ->
      seven_segment_pin = @tlc5947_channel_to_seven_segment_pin[ch] || :ignore
      seven_segment.pgfedcba[seven_segment_pin] || 0
    end)
  end
end
