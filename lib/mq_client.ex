defmodule Mq.Client do
  @moduledoc """
  Client is meant to be an interface from the Mq concept to other possible uses.

  You must supply a callback when calling `Mq.Client.start_link()` to define what happens when a message is received. The callback must be of the form fn ({:topic_message, topic, message)} -> ... end)
  """

  use GenServer

  def start_link(callback, opts) do
    msg_callback =
      case callback do
        nil -> fn -> nil end
        _ -> callback
      end

    GenServer.start_link(__MODULE__, msg_callback, opts)
  end

  @impl true
  def init(callback) do
    {:ok, callback}
  end

  @impl true
  def handle_info({:topic_message, topic, message}, callback) do
    callback.({:topic_message, topic, message})
    {:noreply, callback}
  end
end
