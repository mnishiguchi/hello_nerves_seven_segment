defmodule HelloNervesSevenSegment.HexadecimalClockServer do
  @moduledoc false

  use GenServer

  alias HelloNervesSevenSegment.DisplayServer
  alias HelloNervesSevenSegment.HexadecimalClock

  @inverval_ms 1000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{}, {:continue, :start_ticking}}
  end

  @impl GenServer
  def handle_continue(:start_ticking, state) do
    send(self(), :tick)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    update_display()
    Process.send_after(self(), :tick, @inverval_ms)

    {:noreply, state}
  end

  defp update_display() do
    NaiveDateTime.local_now
    |> HexadecimalClock.new()
    |> HexadecimalClock.clock_face()
    |> DisplayServer.set_characters()
  end
end
