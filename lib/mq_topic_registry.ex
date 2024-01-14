defmodule Mq.TopicRegistry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Lookup a topic with `name` in the `server` registry.
  """
  # Client API
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Create a topic with `name` in the `server` registry.
  """
  def create_topic(server, name) do
    GenServer.call(server, {:create_topic, name})
  end

  @doc """
  Remove the topic with `name` from the `server` registry.
  """
  def remove_topic(server, name) do
    GenServer.call(server, {:remove_topic, name})
  end

  # Server implementation

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, topic}, _from, topics) do
    {:reply, Map.fetch(topics, topic), topics}
  end

  @impl true
  def handle_call({:create_topic, topic}, _from, topics) do
    if Map.has_key?(topics, topic) do
      {:reply, :already_exists, topics}
    else
      {:ok, new_topic} = Mq.Topic.start_link([])
      {:reply, :ok, Map.put(topics, topic, new_topic)}
    end
  end

  @impl true
  def handle_call({:remove_topic, topic}, _from, topics) do
    {:reply, :ok, Map.delete(topics, topic)}
  end
end
