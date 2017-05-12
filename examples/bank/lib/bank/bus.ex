defmodule Bank.Bus do
  @moduledoc "The Eventbus for our app"
  @server __MODULE__

  # API functions
  # Creates an event manager process as part of a supervision tree.
  # The function should be called, directly or indirectly, by the supervisor.
  # It will, among other things, ensure that the event manager is linked to
  # the supervisor.
  def start_link, do: GenEvent.start_link([name: @server])

  def add_handler(handler, args), do: GenEvent.add_handler(@server, handler, args)
  def del_handler(handler, args), do: GenEvent.remove_handler(@server, handler, args)

  def send_command(command), do: GenEvent.notify(@server, command)
  def publish_event(event),  do: GenEvent.notify(@server, event)
end
