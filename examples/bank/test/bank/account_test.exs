defmodule Bank.AccountTest do
  use ExUnit.Case
  doctest Bank.Account
  alias Bank.{Account, Account.State}

  describe "fresh account" do
    setup do
      account = %State{}
      {:ok, account: account}
    end

    test "cannot withdraw money", %{account: account} do
      new_state = Account.attempt_command({:withdraw_money, 100}, account)
      assert 0 = new_state.balance
      assert [%BankAccountPaymentDeclined{id: nil, amount: 100}] = new_state.changes
    end

    test "can deposit money", %{account: account} do
      new_state = Account.attempt_command({:deposit_money, 100}, account)
      assert 100 = new_state.balance
      assert [%BankAccountMoneyDeposited{id: nil, amount: 100}] = new_state.changes
    end

    test "cannot create account twice", %{account: account} do
      first_state = Account.attempt_command({:create, :fake}, account)
      second_state = Account.attempt_command({:create, :fake}, first_state)
      assert first_state.changes == second_state.changes
    end
  end


  describe "250 moneys in account" do
    setup do
      account = %State{balance: 250}
      {:ok, account: account}
    end

    test "cannot withdraw money", %{account: account} do
      new_state = Account.attempt_command({:withdraw_money, 100}, account)
      assert 150 = new_state.balance
      assert [%BankAccountMoneyWithdrawn{id: nil, amount: 100}] = new_state.changes
    end

    test "can deposit money", %{account: account} do
      new_state = Account.attempt_command({:deposit_money, 100}, account)
      assert 350 = new_state.balance
      assert [%BankAccountMoneyDeposited{id: nil, amount: 100}] = new_state.changes
    end

    test "cannot create account twice", %{account: account} do
      first_state = Account.attempt_command({:create, :fake}, account)
      second_state = Account.attempt_command({:create, :fake}, first_state)
      assert first_state.changes == second_state.changes
    end
  end
end
