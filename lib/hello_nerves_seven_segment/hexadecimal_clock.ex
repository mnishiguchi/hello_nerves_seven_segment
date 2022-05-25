defmodule HelloNervesSevenSegment.HexadecimalClock do
  @moduledoc false

  defstruct ~w[hour second]a

  @doc """
  ## Examples

      iex> HexadecimalClock.new(~T[07:20:00])
      %HexadecimalClock{hour: 7, second: 1200}

  """
  def new(%{hour: hour, minute: minute, second: second} \\ Time.utc_now()) do
    %__MODULE__{
      hour: hour |> rem(12),
      second: minute * 60 + second
    }
  end

  @doc """
  ## Examples

      iex> HexadecimalClock.new(~T[00:00:00]) |> HexadecimalClock.clock_face()
      "0000"

      iex> HexadecimalClock.new(~T[07:20:00]) |> HexadecimalClock.clock_face()
      "74B0"

      iex> HexadecimalClock.new(~T[11:40:00]) |> HexadecimalClock.clock_face()
      "B960"

  """
  def clock_face(%__MODULE__{} = clock) do
    [
      clock.hour |> Integer.to_string(16),
      clock.second |> Integer.to_string(16) |> String.pad_leading(3, "0")
    ]
    |> to_string
  end
end
