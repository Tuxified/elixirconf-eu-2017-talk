defmodule Bank.AccountSummaryProjection do
  use GenServer
  @moduledoc "Account summary (read side)"
  @server __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  def project_new_bank_account(id) do
    GenServer.cast(@server, {:project_new_bank_account, id})
  end

  def init([]) do
    state = Bank.ReadStore.get_bank_account_summary()
    {:ok, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast({:project_new_bank_account, _id}, state) do
    new_count = state.count_of_accounts + 1
    new_summary = %BankAccountSummary{state | count_of_accounts: new_count}
    Bank.ReadStore.set_bank_account_summary(new_summary)
    {:noreply, new_summary}
  end

  def handle_cast(_msg, state), do: {:noreply, state}
  def handle_info(_info, state), do: {:noreply, state}
  def terminate(_reason, _state), do: :ok
  def code_change(_old_vsn, state, _extra), do: {:ok, state}
end
