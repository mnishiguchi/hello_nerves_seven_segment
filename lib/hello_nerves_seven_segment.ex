defmodule HelloNervesSevenSegment do
  @moduledoc """
  Documentation for HelloNervesSevenSegment.
  """

  alias HelloNervesSevenSegment.DisplayServer

  def start_demo do
    DisplayServer.start_link()
  end

  def stop_demo do
    DisplayServer.stop()
  end
end
