defmodule TLC5947 do
  @moduledoc """
  A 24-Channel, 12-Bit PWM LED Driver

  ## Examples

  ```
  {:ok, spi} = Circuits.SPI.open("spidev0.0")
  bits = [1, 1, 1, 0, 0, 0]
  tlc5947 = TLC5947.new(bits: bits)
  Circuits.SPI.transfer(spi, tlc5947.data)
  ```

  ## Data sheet

  https://cdn-shop.adafruit.com/datasheets/tlc5947.pdf

  """

  defstruct brightness: 0, data: <<>>

  @default_brightness 0x060
  @max_brightness 0xFFF

  def new(opts) do
    bits = opts[:bits] || []
    brightness = opts[:brightness] || @default_brightness

    %__MODULE__{
      brightness: brightness,
      data: to_tlc5947_words(bits, brightness)
    }
  end

  @doc """
  Convert a list of 24 bits to TLC5947 words as bitstring

  ## Examples

      iex> TLC5947.to_tlc5947_words([1, 0, 1, 1], 0x060)
      <<96::12, 96::12, 0::12, 96::12, 0::(12 * 20)>>

      iex> TLC5947.to_tlc5947_words([1, 1, 1, 1], 0x000)
      <<0::(12 * 24)>>

      iex> TLC5947.to_tlc5947_words([1, 1, 1], 0xfff + 1)
      ** (FunctionClauseError) no function clause matching in TLC5947.to_tlc5947_words/2

      iex> TLC5947.to_tlc5947_words([], 0x060)
      <<0::(12 * 24)>>
  """
  def to_tlc5947_words(bits, brightness)
      when is_list(bits) and brightness <= @max_brightness do
    for bit <- bits |> zero_pad_list(24) |> Enum.reverse(), into: <<>> do
      case bit do
        0 -> <<0::12>>
        1 -> <<brightness::12>>
        _ -> raise("bit must be either 0 or 1")
      end
    end
  end

  @doc """
  Zero-pads a number list.

  ## Examples

      iex> TLC5947.zero_pad_list([1, 2, 3], 6)
      [0, 0, 0, 1, 2, 3]

  """
  @spec zero_pad_list([non_neg_integer], non_neg_integer) :: [0 | 1]
  def zero_pad_list(numbers, total_length \\ 6) do
    padding = List.duplicate(0, total_length - length(numbers))
    padding ++ numbers
  end
end
