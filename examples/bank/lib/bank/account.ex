defmodule Bank.Account do
  require Logger
  @moduledoc """
  This is our 'Aggregate', which computes state based on commands/events
  """

  defmodule State do
    @moduledoc "Holds represantation of current state of Aggregate"
    defstruct [:id, :date_created, balance: 0, changes: []]
  end

  @process_time_out 180_000

  # API
  def new, do: spawn(__MODULE__, :init, [])

  def create(pid, id) do
    send pid, {:attempt_command, {:create, id}}
  end

  def deposit_money(pid, amount) do
    send pid, {:attempt_command, {:deposit_money, amount}}
  end

  def withdraw_money(pid, amount) do
    send pid, {:attempt_command, {:withdraw_money, amount}}
  end

  def process_unsaved_changes(pid, saver) do
    send pid, {:process_unsaved_changes, saver}
  end

  def load_from_history(pid, events) do
    send pid, {:load_from_history, events}
  end

  # Internals
  def init, do: loop(%State{})

  defp loop(%State{id: id} = state) do
    Logger.info(fn() -> "Process #{inspect self()} state:[#{inspect state}]\n" end)

    receive do
      {:apply_event, event} ->
        new_state = apply_event(event, state)
        loop(new_state)
      {:attempt_command, command} ->
        new_state = attempt_command(command, state)
        loop(new_state)
      {:process_unsaved_changes, saver} ->
        id = state.id
        saver.(id, Enum.reverse(state.changes))
        new_state = %State{state | changes: []}
        loop(new_state)
      {:load_from_history, events} ->
        new_state = apply_many_events(events, %State{})
        loop(new_state)
      {:system, {from, reference}, :get_state} ->
        send from, {reference, state}
        loop(state)
      unknown ->
        Logger.warn(fn() -> "Received unknown message (#{inspect unknown})\n" end)
        loop(state)
      after @process_time_out ->
        Bank.AccountRepository.remove_from_cache(id)
        exit(:normal)
    end
  end

  def attempt_command({:create, id}, state) do
    case state.changes do
      [] ->
        event = %BankAccountCreated{id: id, date_created: :erlang.localtime()}
        apply_new_event(event, state)
      _ ->
        Logger.info(fn() -> "Account #{inspect id} already exists" end)
        state
    end
  end

  def attempt_command({:deposit_money, amount}, state) do
    new_balance = state.balance + amount

    event = %BankAccountMoneyDeposited{id: state.id, amount: amount,
      new_balance: new_balance, transaction_date: :erlang.localtime()}
    apply_new_event(event, state)
  end

  def attempt_command({:withdraw_money, amount}, state) do
    (state.balance - amount)
    |> attempt_withdrawal(state.id, amount)
    |> apply_new_event(state)
  end

  def attempt_command(command, state) do
    Logger.warn(fn() -> "attempt_command for unexpected command (#{inspect command})\n" end)
    state
  end

  def apply_new_event(event, state) do
    new_state = apply_event(event, state)
    %State{new_state | changes: [event | new_state.changes]}
  end

  def apply_event(%BankAccountCreated{id: id, date_created: date_created}, state) do
    Bank.AccountRepository.add_to_cache(id)
    %State{state | id: id, date_created: date_created}
  end

  def apply_event(%BankAccountMoneyDeposited{amount: amount}, %State{balance: balance} = state) do
    %State{state | balance: balance + amount}
  end

  def apply_event(%BankAccountMoneyWithdrawn{amount: amount}, %State{balance: balance} = state) do
    %State{state | balance: balance - amount}
  end

  def apply_event(_event, state) do
    state # For other events, we don't have state to mutate
  end

  def apply_many_events([], state) do
    state
  end

  def apply_many_events([event|rest], state) do
    new_state = apply_event(event, state)
    apply_many_events(rest, new_state)
  end

  defp attempt_withdrawal(new_balance, id, amount) when new_balance < 0 do
    %BankAccountPaymentDeclined{id: id, amount: amount,
      transaction_date: :erlang.localtime()}
  end

  defp attempt_withdrawal(new_balance, id, amount) do
    %BankAccountMoneyWithdrawn{id: id, amount: amount, new_balance: new_balance,
      transaction_date: :erlang.localtime()}
  end
end
