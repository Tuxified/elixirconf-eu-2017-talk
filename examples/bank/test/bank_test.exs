defmodule BankTest do
  use ExUnit.Case
  doctest Bank

  # Smoke/integration tests, needs sleeps
  # since read side "lags behind", is eventually
  # consistent

  test "create account" do
    assert :ok = Bank.create(1)
  end

  test "deposit moneys" do
    Bank.create(:wolfman)
    Process.sleep(10)
    Bank.deposit(:wolfman, 10)
    Process.sleep(10)
    assert Bank.check_balance(:wolfman) == 10
  end

  test "withdraw moneys" do
    Bank.create(:dracula)
    Process.sleep(10)
    Bank.deposit(:dracula, 100)
    Process.sleep(10)
    Bank.withdraw(:dracula, 10)
    Process.sleep(10)
    assert 90 == Bank.check_balance(:dracula)
  end
end
