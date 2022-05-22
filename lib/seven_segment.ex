defmodule SevenSegment do
  @moduledoc """
  The seven-segment display core logic.
  """

  use Bitwise

  @pgfedcba_byte_common_cathode %{
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
            display_type: nil,
            pgfedcba: %{}

  def new(opts) do
    character = Access.fetch!(opts, :character)
    display_type = Access.fetch!(opts, :display_type)
    with_dot = Access.get(opts, :with_dot, false)

    %__MODULE__{
      character: character,
      display_type: display_type,
      pgfedcba: build_pgfedcba(character, display_type, with_dot)
    }
  end

  defp build_pgfedcba(character, display_type, with_dot) do
    if with_dot do
      character
      |> char_to_pgfedcba(display_type)
      |> add_dot_to_pgfedcba(display_type)
      |> pgfedcba_to_map()
    else
      character
      |> char_to_pgfedcba(display_type)
      |> pgfedcba_to_map()
    end
  end

  @doc """
  Converts a character to the GFEDCBA byte

  ## Examples

      ## Common cathode

      iex> char_to_pgfedcba('A', :common_cathode)
      0b0111_0111

      iex> char_to_pgfedcba('A', :common_cathode) |> add_dot_to_pgfedcba(:common_cathode)
      0b1111_0111

      iex> char_to_pgfedcba('A', :common_cathode) |> add_dot_to_pgfedcba(:common_cathode) |> pgfedcba_to_map
      %{a: 1, b: 1, c: 1, d: 0, e: 1, f: 1, g: 1, p: 1}

      ## Common anode

      iex> char_to_pgfedcba('A', :common_anode)
      0b1000_1000

      iex> char_to_pgfedcba('A', :common_anode) |> add_dot_to_pgfedcba(:common_anode)
      0b0000_1000

      iex> char_to_pgfedcba('A', :common_anode) |> add_dot_to_pgfedcba(:common_anode) |> pgfedcba_to_map
      %{a: 0, b: 0, c: 0, d: 1, e: 0, f: 0, g: 0, p: 0}

  """
  def char_to_pgfedcba(char, type) when is_list(char) do
    case type do
      :common_cathode ->
        Access.fetch!(@pgfedcba_byte_common_cathode, char)

      :common_anode ->
        Access.fetch!(@pgfedcba_byte_common_cathode, char) |> bxor(0b1111_1111)
    end
  end

  @doc """
  Add a decimal-point flag to a pgfedcba byte.

  ## Examples

      iex> add_dot_to_pgfedcba(0b0000_0111, :common_cathode)
      0b1000_0111

      iex> add_dot_to_pgfedcba(0b1111_1000, :common_anode)
      0b0111_1000

  """
  def add_dot_to_pgfedcba(pgfedcba, type) when is_integer(pgfedcba) do
    case type do
      :common_cathode ->
        # add a flag
        pgfedcba ||| @decimal_point_mask

      :common_anode ->
        # remove a flag
        pgfedcba &&& ~~~@decimal_point_mask
    end
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
