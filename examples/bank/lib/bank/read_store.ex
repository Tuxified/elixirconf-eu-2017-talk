defmodule Bank.ReadStore do
   @moduledoc """
   Using ets for the read store is fine for this demo, but the data
   will be discarded when the creating process dies, and there is no
   automatic garbage collection for ets tables.
   """

  def init do
    :ets.new(:read_store, [:public, :named_table])
    set_bank_account_summary(%BankAccountSummary{})
    set_bank_account_details([])
    :ok
  end

  def get_bank_account_summary do
    [{:summary, summary}] = :ets.lookup(:read_store, :summary)
    summary
  end

  def set_bank_account_summary(new_data) do
    :ets.insert(:read_store, {:summary, new_data})
  end

  def get_bank_account_details do
    [{:details, details}] = :ets.lookup(:read_store, :details)
    details
  end

  def set_bank_account_details(new_data) do
    :ets.insert(:read_store, {:details, new_data})
  end
end
