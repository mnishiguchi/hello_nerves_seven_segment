defmodule SevenSegment do
  @moduledoc """
  The generic logic for a seven-segment display.
  """

  use Bitwise

  @pgfedcba_byte %{
    nil => 0b0000_0000,
    ' ' => 0b0000_0000,
    '0' => 0b0011_1111,
    '1' => 0b0000_0110,
    '2' => 0b0101_1011,
    '3' => 0b0100_1111,
    '4' => 0b0110_0110,
    '5' => 0b0110_1101,
    '6' => 0b0111_1101,
    '7' => 0b0000_0111,
    '8' => 0b0111_1111,
    '9' => 0b0110_1111,
    'A' => 0b0111_0111,
    'B' => 0b0111_1100,
    'C' => 0b0011_1001,
    'D' => 0b0101_1110,
    'E' => 0b0111_1001,
    'F' => 0b0111_0001
  }

  @decimal_point_mask 0b1000_0000

  defstruct character: nil,
            bit_flip: false,
            pgfedcba: %{}

  def new(opts) do
    character = Access.fetch!(opts, :character)
    bit_flip = Access.get(opts, :bit_flip, false)
    with_dot = Access.get(opts, :with_dot, false)

    %__MODULE__{
      character: character,
      bit_flip: bit_flip,
      pgfedcba: build_pgfedcba(character, with_dot, bit_flip)
    }
  end

  defp build_pgfedcba(character, with_dot, bit_flip) do
    character
    |> char_to_pgfedcba()
    |> maybe_add_dot_to_pgfedcba(with_dot)
    |> pgfedcba_to_map()
    |> maybe_flip_bits(bit_flip)
  end

  defp maybe_add_dot_to_pgfedcba(pgfedcba, false), do: pgfedcba
  defp maybe_add_dot_to_pgfedcba(pgfedcba, true), do: add_dot_to_pgfedcba(pgfedcba)
  defp maybe_flip_bits(byte, false), do: byte
  defp maybe_flip_bits(byte, true), do: bxor(byte, 0b1111_1111)

  @doc """
  Converts a character to the GFEDCBA byte

  ## Examples

      iex> char_to_pgfedcba('A')
      0b0111_0111

      iex> char_to_pgfedcba(65)
      ** (RuntimeError) unsupported character: 65

  """
  def char_to_pgfedcba(character) when is_list(character) do
    Access.fetch!(@pgfedcba_byte, character)
  end

  def char_to_pgfedcba(unsupported) do
    raise("unsupported character: #{inspect(unsupported)}")
  end

  @doc """
  Add a decimal-point flag to a pgfedcba byte.

  ## Examples

      iex> add_dot_to_pgfedcba(0b0000_0111)
      0b1000_0111

  """
  def add_dot_to_pgfedcba(pgfedcba) when is_integer(pgfedcba) do
    pgfedcba ||| @decimal_point_mask
  end

  @doc """
  Converts a pgfedcba byte to a map.

  ## Examples

      iex> pgfedcba_to_map(0b1000_1000)
      %{a: 0, b: 0, c: 0, d: 1, e: 0, f: 0, g: 0, p: 1}

  """
  def pgfedcba_to_map(pgfedcba) when is_integer(pgfedcba) do
    padded_bits = pgfedcba |> Integer.digits(2) |> zero_pad_list(8)
    ~w(p g f e d c b a)a |> Enum.zip(padded_bits) |> Map.new()
  end

  @doc """
  Zero-pads a number list.

  ## Examples

      iex> zero_pad_list([1, 2, 3], 6)
      [0, 0, 0, 1, 2, 3]

  """
  @spec zero_pad_list([non_neg_integer], non_neg_integer) :: [0 | 1]
  def zero_pad_list(numbers, total_length \\ 8) do
    padding = List.duplicate(0, total_length - length(numbers))
    padding ++ numbers
  end
end
