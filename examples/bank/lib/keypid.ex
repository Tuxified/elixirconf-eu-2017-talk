defmodule Keypid do
  @moduledoc """
  Registry of instantiated aggregates so we don't have 2 of them alive at
  the same time. Aggregates stay alive for 45s (when inactive). Volatile
  aggregates will stay alive longer.
  """
  @table_id __MODULE__

  def init do
    # :ets.new(@table_id, [:public, :named_table])
    Registry.start_link(:unique, @table_id)
    :ok
  end

  def delete(key) do
    # :ets.delete(@table_id, key)
    Registry.unregister(@table_id, key)
  end

  def save(key, pid) do
    save_helper(key, pid, is_pid(pid))
  end

  defp save_helper(key, pid, true) do
    # :ets.insert(@table_id, {key, pid})
    Registry.register(@table_id, key, pid)
  end

  defp save_helper(_, _, _) do
    false
  end

  def get(key) do
    with [{_self, pid}] <- Registry.lookup(@table_id, key),
      true <- is_pid(pid) && Process.alive?(pid)
    do
      pid
    else
      _ -> :not_found
    end
  end
end
