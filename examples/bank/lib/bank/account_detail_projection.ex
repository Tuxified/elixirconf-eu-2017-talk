defmodule Bank.AccountDetailProjection do
  use GenServer
  require Logger
  @server __MODULE__

  @moduledoc """
  Account detail Projection which updates the read side when new events come in
  """

  # API Function Definitions
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  def process_event(event) do
    Logger.info(fn() -> "Projection process_event: #{inspect event}." end)
    GenServer.cast(@server, event)
  end

  # gen_server Function Definitions
  def init([]) do
    list = Bank.ReadStore.get_bank_account_details()
    details = :dict.from_list(list)
    {:ok, details}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(%BankAccountCreated{id: id}, details) do
    new_details = :dict.store(id, 0, details)
    update_read_store(new_details)
    {:noreply, new_details}
  end

  def handle_cast(%BankAccountMoneyWithdrawn{id: id, new_balance: balance}, details) do
    new_details = :dict.store(id, balance, details)
    update_read_store(new_details)
    {:noreply, new_details}
  end

  def handle_cast(%BankAccountPaymentDeclined{id: id}, details) do
    Logger.info(fn() -> "Payment declined for Account: #{inspect id}. Shame, shame!\n" end)
    {:noreply, details}
  end

  def handle_cast(%BankAccountMoneyDeposited{id: id, new_balance: balance}, details) do
    new_details = :dict.store(id, balance, details)
    update_read_store(new_details)
    {:noreply, new_details}
  end

  defp update_read_store(details) do
    Bank.ReadStore.set_bank_account_details(:dict.to_list(details))
  end
end
