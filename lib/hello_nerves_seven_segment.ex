defmodule HelloNervesSevenSegment do
  @moduledoc """
  Documentation for HelloNervesSevenSegment.
  """

  alias HelloNervesSevenSegment.Core

  def demo(repeat_n \\ 50) do
    {:ok, spi} = Circuits.SPI.open("spidev0.0")

    # {:ok, digit1} = Circuits.GPIO.open(6, :output)
    {:ok, digit2} = Circuits.GPIO.open(13, :output)
    {:ok, digit3} = Circuits.GPIO.open(19, :output)
    {:ok, digit4} = Circuits.GPIO.open(26, :output)

    for _ <- 1..repeat_n,
        {character, gpio} <- [{'1', digit2}, {'0', digit3}, {'0', digit4}] do
      Core.transfer(spi: spi, brightness: 0xFFF, character: character)
      Circuits.GPIO.write(gpio, 1)

      Process.sleep(7)

      Circuits.GPIO.write(gpio, 0)
    end
  end
end
