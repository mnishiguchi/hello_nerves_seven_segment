defmodule HelloNervesSevenSegmentTest do
  use ExUnit.Case
  doctest HelloNervesSevenSegment

  test "greets the world" do
    assert HelloNervesSevenSegment.hello() == :world
  end
end
