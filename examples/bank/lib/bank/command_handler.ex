defmodule Bank.CommandHandler do
  use GenEvent

  @moduledoc """
  Our CommandHandler which handles incoming Commands by producing Events
  """

  def add_handler, do: Bank.Bus.add_handler(__MODULE__, [])
  def del_handler, do: Bank.Bus.del_handler(__MODULE__, [])

  def init([]) do
    {:ok, []}
  end

  def handle_event(%CreateBankAccount{id: id}, state) do
    case Bank.AccountRepository.get_by_id(id) do
      :not_found ->
        pid = Bank.Account.new()
        Bank.Account.create(pid, id)
        Bank.AccountRepository.save(pid)
        {:ok, state}
      _ ->
        {:ok, state}
    end
  end

  def handle_event(%DepositMoneyIntoBankAccount{id: id, amount: amount}, state) do
    case Bank.AccountRepository.get_by_id(id) do
      :not_found ->
        {:ok, state}
      {:ok, pid} ->
        Bank.Account.deposit_money(pid, amount)
        Bank.AccountRepository.save(pid)
        {:ok, state}
    end
  end

  def handle_event(%WithdrawMoneyFromBankAccount{id: id, amount: amount}, state) do
    case Bank.AccountRepository.get_by_id(id) do
      :not_found ->
        {:ok, state}
      {:ok, pid} ->
        Bank.Account.withdraw_money(pid, amount)
        Bank.AccountRepository.save(pid)
        {:ok, state}
    end
  end

  def handle_event(_, state) do
    {:ok, state}
  end
end
