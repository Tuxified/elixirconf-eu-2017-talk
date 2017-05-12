defmodule Bank.Supervisor do
  use Supervisor
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Bank.Bus, []),
      worker(Bank.AccountSummaryProjection, []),
      worker(Bank.AccountDetailProjection, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
