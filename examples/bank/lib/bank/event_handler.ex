defmodule Bank.EventHandler do
  use GenEvent

  @moduledoc """
  Event handler which upon new events updates the read side.
  """

  def add_handler, do: Bank.Bus.add_handler(__MODULE__, [])
  def del_handler, do: Bank.Bus.del_handler(__MODULE__, [])

  def init([]) do
    {:ok, []}
  end

  def handle_event(%BankAccountCreated{id: id} = event, state) do
    Bank.AccountSummaryProjection.project_new_bank_account(id)
    Bank.AccountDetailProjection.process_event(event)
    {:ok, state}
  end

  def handle_event(%BankAccountMoneyDeposited{} = event, state) do
    Bank.AccountDetailProjection.process_event(event)
    {:ok, state}
  end

  def handle_event(%BankAccountMoneyWithdrawn{} = event, state) do
    Bank.AccountDetailProjection.process_event(event)
    {:ok, state}
  end

  def handle_event(%BankAccountPaymentDeclined{} = event, state) do
    Bank.AccountDetailProjection.process_event(event)
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end
end
