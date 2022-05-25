defmodule HelloNervesSevenSegment.DisplayTest do
  use ExUnit.Case
  alias HelloNervesSevenSegment.Display

  describe "new/1" do
    test "at least does not crash with valid params" do
      valid_params = %{spi: fake_spi(), gpio: fake_gpio()}

      assert %Display{} = Display.new(valid_params)
    end

    test "raise KeyError when required param key missing" do
      assert_raise KeyError, fn ->
        Display.new(%{invalid: 1})
      end
    end
  end

  describe "show_character/1" do
    test "at least does not crash with valid struct" do
      valid_params = %{spi: fake_spi(), gpio: fake_gpio()}

      assert :ok = Display.new(valid_params) |> Display.show_character("A")
    end
  end

  defp fake_gpio, do: {make_ref(), make_ref(), make_ref(), make_ref()}

  defp fake_spi, do: make_ref()
end
