defmodule TLC5947.Cache do
  @moduledoc false

  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> build_initial_state() end, name: __MODULE__)
  end

  def get_or_insert_by(params, tlc5947_builder) do
    case get_by(params) do
      nil ->
        tlc5947 = tlc5947_builder.(params)
        :ok = save(params, tlc5947)
        tlc5947

      tlc5947 ->
        tlc5947
    end
  end

  defp build_initial_state() do
    %{}
  end

  defp get_by(params) do
    value = Agent.get(__MODULE__, &get_in(&1, [build_cache_key(params)]))
    value.tlc5947
  end

  defp save(params, tlc5947) do
    Agent.update(__MODULE__, &put_in(&1, [build_cache_key(params)], build_cache_value(tlc5947)))
  end

  defp build_cache_key(params) do
    brightness = Access.fetch!(params, :brightness)
    character = params[:character]
    bit_flip = params[:bit_flip]

    {brightness, character, bit_flip}
  end

  defp build_cache_value(tlc5947) do
    %{
      tlc5947: tlc5947,
      time: DateTime.utc_now()
    }
  end
end
