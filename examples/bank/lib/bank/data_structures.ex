# Projections
defmodule BankAccountSummary do
  @moduledoc "Projection which keeps track of total # of accounts"
  defstruct [count_of_accounts: 0]
end

# Commands
defmodule CreateBankAccount do
  @moduledoc "Command when account is being created"
  @enforce_keys [:id]
  defstruct [:id]
end

defmodule DepositMoneyIntoBankAccount do
  @moduledoc "Command when amount is being depositedc"
  @enforce_keys [:id]
  defstruct [:id, amount: 0]
end

defmodule WithdrawMoneyFromBankAccount do
  @moduledoc "Command when amount from account is being withdrawn"
  @enforce_keys [:id]
  defstruct [:id, amount: 0]
end

# Events
defmodule BankAccountCreated do
  @moduledoc "Event when new bank account has been created"
  @enforce_keys [:id, :date_created]
  defstruct [:id, :date_created]
end

defmodule BankAccountMoneyDeposited do
  @moduledoc "Event when amount is deposited to account"
  @enforce_keys [:id]
  defstruct [:id, :transaction_date, amount: 0, new_balance: 0]
end

defmodule BankAccountMoneyWithdrawn do
  @moduledoc "Event when amount is withdrawn"
  @enforce_keys [:id]
  defstruct [:id, :transaction_date, amount: 0, new_balance: 0]
end

defmodule BankAccountPaymentDeclined do
  @moduledoc "Event when withdrawal cannot be approved"
  @enforce_keys [:id]
  defstruct [:id, :transaction_date, amount: 0]
end
