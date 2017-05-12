# Simple Bank example

A simple example of a "Bank" to show how the concepts from CQRS/ES map
on Elixir/Erlang. This is not a recommended production example, just a
barebones-no-dependencies Elixirification of [Bryan Hunters version](
https://github.com/bryanhunter/cqrs-with-erlang)

Steps to explore/tryout:
- bootup in REPL: `iex -S mix`
- create account: `Bank.create :me`
- deposit some €: `Bank.deposit :me, 100`
- withdraw some : `Bank.withdraw :me, 10`
- check balance : `Bank.check_balance :me`
- inspect tables: `:observer.start`, take a look at tables tab

Uses ETS for eventstore (1 entry per aggregate/account) & readstore, GenEvent for Command/EventHandlers, GenServer for account projections, Registry for keeping track of "alive" Aggregates (bank accounts).

Slides for introductionary talk about CQRS/ES (given at ElixirConfEU 2017):
[https://tuxified.github.io/elixirconf-eu-2017-talk](https://tuxified.github.io/elixirconf-eu-2017-talk)
