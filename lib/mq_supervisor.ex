defmodule Mq.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Mq.TopicRegistry, name: Mq.TopicRegistryInstance},
      {DynamicSupervisor, name: Mq.TopicSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Client API

  @doc """
  Adds a `pid` to a topic's (With name `topic`) list of subscribers.

  Will create the topic if it does not already exist.
  """
  def subscribe(pid, topic_name) do
    target_topic =
      case Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, topic_name) do
        {:ok, topic} ->
          topic

        :error ->
          Mq.TopicRegistry.create_topic(Mq.TopicRegistryInstance, topic_name)
      end

    Mq.Topic.add(target_topic, pid)
  end

  @doc """
  Removes a `pid` from a `topic`.

  The function will always be successful, even if the topic does not exist.
  """
  def unsubscribe(pid, topic_name) do
    case Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, topic_name) do
      {:ok, topic} ->
        Mq.Topic.remove(topic, pid)
        :ok

      :error ->
        :ok
    end
  end
end
