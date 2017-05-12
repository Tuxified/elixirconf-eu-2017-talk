defmodule Bank.EventStore do

  @moduledoc """
  Using ets for an event store is fine for a demo, but the data
  will be discarded when the creating process dies, and there is no
  automatic garbage collection for ets tables.
  """

  @table_id __MODULE__

  def init do
    :ets.new(@table_id, [:public, :named_table])
    :ok
  end

  def append_events(key, events) do
    stored_events = get_raw_events(key)
    new_events = Enum.reverse(events)
    combined_events = new_events ++ stored_events
    :ets.insert(@table_id, {key, combined_events})

    Enum.each(new_events, fn(event) -> Bank.Bus.publish_event(event) end)
  end

  def get_events(key) do
    Enum.reverse(get_raw_events(key))
  end

  def delete(key) do
    :ets.delete(@table_id, key)
  end

  defp get_raw_events(key) do
    case :ets.lookup(@table_id, key) do
      [{^key, events}] -> events
      [] -> []
    end
  end
end
