defmodule HelloNervesSevenSegment.Core do
  @moduledoc """
  ## Examples

  ```
  {:ok, spi} = Circuits.SPI.open("spidev0.0")

  display = SevenSegment.new(character: '1', display_type: :common_cathode)
  bits = HelloNervesSevenSegment.Core.display_to_bits(display)
  tlc5947 = TLC5947.new(bits: bits)
  Circuits.SPI.transfer(spi, tlc5947.data)

  test_fn = fn ->
    for codepoint <- Enum.concat(?0..?9, ?A..?F) do
      HelloNervesSevenSegment.Core.transfer(spi: spi, character: [codepoint], display_type: :common_cathode)
      :timer.sleep(500)
    end
  end
  ```
  """

  @tlc5947_channel_to_display_pin %{
    0 => :e,
    1 => :d,
    2 => :p,
    3 => :c,
    4 => :g,
    5 => :display4,
    6 => :b,
    7 => :display3,
    8 => :display2,
    9 => :f,
    10 => :a,
    11 => :display1
  }

  def transfer(opts) do
    spi = Access.fetch!(opts, :spi)
    bits = display_to_bits(SevenSegment.new(opts))
    brightness = opts[:brightness]
    tlc5947 = TLC5947.new(bits: bits, brightness: brightness)
    Circuits.SPI.transfer(spi, tlc5947.data)
  end

  @doc """
  Map a SevenSegment struct to bits
  """
  def display_to_bits(display) do
    display_map = display.pgfedcba |> Enum.into(display.enabled)

    0..23
    |> Enum.map(fn ch ->
      display_pin = @tlc5947_channel_to_display_pin[ch] || :ignore
      display_map[display_pin] || 0
    end)
  end
end
