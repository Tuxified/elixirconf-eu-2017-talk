defmodule Bank do
  use Application
  alias Bank.{Bus, EventStore, ReadStore}
  @moduledoc """
  Documentation for Bank.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Bank.hello
      :world

  """
  def hello do
    :world
  end

  def start(_start_type \\ nil, _start_args \\ nil)
  def start(_start_type, _start_args) do
    EventStore.init()
    ReadStore.init()
    Keypid.init()

    case Bank.Supervisor.start_link() do
      {:ok, pid} ->
        Bank.CommandHandler.add_handler()
        Bank.EventHandler.add_handler()
        {:ok, pid}
      other ->
        {:error, other}
    end
  end

  def open, do: Application.start(:bank)
  def close, do: Application.stop(:bank)

  def create(account) do
    Bus.send_command(%CreateBankAccount{id: account})
  end

  def deposit(account, amount) do
    Bus.send_command(%DepositMoneyIntoBankAccount{id: account, amount: amount})
  end

  def withdraw(account, amount) do
    Bus.send_command(%WithdrawMoneyFromBankAccount{id: account, amount: amount})
  end

  def check_balance(account) do
    details = ReadStore.get_bank_account_details()
    dict = :dict.from_list(details)
    case :dict.find(account, dict) do
      {:ok, value} -> value
      _ -> :no_such_account
    end
  end
end
