defmodule HelloNervesSevenSegment.HexadecimalClockSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      HelloNervesSevenSegment.DisplayServer,
      HelloNervesSevenSegment.HexadecimalClockServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
