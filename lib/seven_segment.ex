defmodule SevenSegment do
  @moduledoc """
  The generic logic for a seven-segment display.
  """

  use Bitwise

  @character_to_pgfedcba_byte %{
    # blank
    nil => 0b0000_0000,
    ' ' => 0b0000_0000,
    '.' => 0b1000_0000,
    # 0..9
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
    '0.' => 0b1011_1111,
    '1.' => 0b1000_0110,
    '2.' => 0b1101_1011,
    '3.' => 0b1100_1111,
    '4.' => 0b1110_0110,
    '5.' => 0b1110_1101,
    '6.' => 0b1111_1101,
    '7.' => 0b1000_0111,
    '8.' => 0b1111_1111,
    '9.' => 0b1110_1111,
    # A..F
    'A' => 0b0111_0111,
    'B' => 0b0111_1100,
    'C' => 0b0011_1001,
    'D' => 0b0101_1110,
    'E' => 0b0111_1001,
    'F' => 0b0111_0001,
    'A.' => 0b1111_0111,
    'B.' => 0b1111_1100,
    'C.' => 0b1011_1001,
    'D.' => 0b1101_1110,
    'E.' => 0b1111_1001,
    'F.' => 0b1111_0001
  }

  defstruct character: nil,
            bit_flip: false,
            pgfedcba: %{}

  @doc """
  ## Examples

      iex> SevenSegment.new(character: 'A')
      %SevenSegment{
        bit_flip: false,
        character: 'A',
        pgfedcba: %{a: 1, b: 1, c: 1, d: 0, e: 1, f: 1, g: 1, p: 0}
      }

      iex> new(character: 'A', bit_flip: true)
      %SevenSegment{
        bit_flip: true,
        character: 'A',
        pgfedcba: %{a: 0, b: 0, c: 0, d: 1, e: 0, f: 0, g: 0, p: 1}
      }

  """
  def new(opts) do
    character = Access.fetch!(opts, :character) |> normalize_character()
    bit_flip = Access.get(opts, :bit_flip, false)

    %__MODULE__{
      character: character,
      bit_flip: bit_flip,
      pgfedcba: build_pgfedcba(character, bit_flip)
    }
  end

  defp build_pgfedcba(character, bit_flip) do
    character
    |> character_to_pgfedcba_byte()
    |> maybe_flip_bits(bit_flip)
    |> pgfedcba_to_map()
  end

  defp maybe_flip_bits(byte, false), do: byte
  defp maybe_flip_bits(byte, true), do: bxor(byte, 0b1111_1111)

  @doc """
  Converts a character to the GFEDCBA byte

  ## Examples

      iex> character_to_pgfedcba_byte('A')
      0b0111_0111

  """
  def character_to_pgfedcba_byte(character) do
    Access.fetch!(@character_to_pgfedcba_byte, character)
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

  @doc """
  Normalizes the character to the supported format.

  ## Examples

      iex> normalize_character('A')
      'A'

      iex> normalize_character("A")
      'A'

      iex> normalize_character("a")
      'A'

      iex> normalize_character("a.")
      'A.'

      iex> normalize_character(" A. ")
      'A.'

  """
  def normalize_character(character) do
    case character |> to_string() |> String.trim() |> String.upcase() do
      <<x, 46>> -> [x, 46]
      <<x>> -> [x]
    end
  end
end
