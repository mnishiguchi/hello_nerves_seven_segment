defmodule HelloNervesSevenSegment.Core do
  @moduledoc """
  The core logic of this app.

  ## Examples

  ```
  alias HelloNervesSevenSegment.Core

  {:ok, spi} = Circuits.SPI.open("spidev0.0")
  {:ok, enable1} = Circuits.GPIO.open(6, :output)
  {:ok, enable2} = Circuits.GPIO.open(13, :output)
  {:ok, enable3} = Circuits.GPIO.open(19, :output)
  {:ok, enable4} = Circuits.GPIO.open(26, :output)

  test_fn = fn ->
    for _ <- 0..999,
        {character, gpio} <- [{'1', enable2}, {'0', enable3}, {'0', enable4}] do
      Circuits.GPIO.write(gpio, 1)
      Core.transfer(spi: spi, character: character, display_type: :common_cathode, brightness: 0xFFF)
      :timer.sleep(2)
      Core.transfer(spi: spi, character: character, display_type: :common_cathode, brightness: 0x000)
      Circuits.GPIO.write(gpio, 0)
    end
  end

  test_fn.()

  ```
  """

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
    bits = seven_segment_to_bits(SevenSegment.new(opts))
    tlc5947 = TLC5947.new(bits: bits, brightness: opts[:brightness])
    Circuits.SPI.transfer(spi, tlc5947.data)
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

      iex> seven_segment_to_bits(SevenSegment.new(character: 'F', display_type: :common_cathode))
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
