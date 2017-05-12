defmodule Bank.AccountRepository do
  @moduledoc """
  Repository which forwards Events to EvenStore and instantiates/uses Aggregates
  """

  def add_to_cache(id) do
    Keypid.save(id, self())
  end

  def remove_from_cache(id) do
    Keypid.delete(id)
  end

  def get_by_id(id) do
    case Keypid.get(id) do
      :not_found -> load_from_event_store(id)
      pid -> {:ok, pid}
    end
  end

  def save(pid) do
    saver = fn(id, events) ->
      Bank.EventStore.append_events(id, events)
    end

    Bank.Account.process_unsaved_changes(pid, saver)
  end

  defp load_from_event_store(id) do
    case Bank.EventStore.get_events(id) do
      [] ->
        :not_found
      events ->
        pid = Bank.Account.new()
        Bank.Account.load_from_history(pid, events)
        {:ok, pid}
    end
  end
end
