defmodule HelloNervesSevenSegment do
  @moduledoc """
  Documentation for HelloNervesSevenSegment.
  """

  alias HelloNervesSevenSegment.DisplayServer

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []) do
    DisplayServer.start_link(opts)
  end

  @spec stop :: :ok
  def stop do
    DisplayServer.stop()
  end

  @spec set_characters(list | tuple) :: any
  def set_characters(characters) do
    DisplayServer.set_characters(characters)
  end
end
