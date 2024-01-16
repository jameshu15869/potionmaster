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

  @doc """
  Publish `message` to `topic`.
  """
  def publish(server, topic, message) do
    GenServer.call(server, {:publish, topic, message})
  end

  # Server implementation

  @impl true
  def init(:ok) do
    topics = %{}
    refs = %{}
    {:ok, {topics, refs}}
  end

  @impl true
  def handle_call({:lookup, topic}, _from, state) do
    {topics, _} = state
    {:reply, Map.fetch(topics, topic), state}
  end

  @impl true
  def handle_call({:create_topic, topic}, _from, {topics, refs}) do
    if Map.has_key?(topics, topic) do
      {:reply, topic, topics}
    else
      {:ok, new_topic} = DynamicSupervisor.start_child(Mq.TopicSupervisor, Mq.Topic)
      ref = Process.monitor(new_topic)
      refs = Map.put(refs, ref, topic)
      topics = Map.put(topics, topic, new_topic)
      {:reply, new_topic, {topics, refs}}
    end
  end

  @impl true
  def handle_call({:remove_topic, topic}, _from, {topics, refs}) do
    topics = Map.delete(topics, topic)
    {:reply, :ok, {topics, refs}}
  end

  @impl true
  def handle_call({:publish, topic_name, message}, _from, {topics, refs}) do
    if Map.has_key?(topics, topic_name) do
      {:ok, topic_pid} = Map.fetch(topics, topic_name)

      Mq.Topic.publish_message(topic_pid, topic_name, message)
      {:reply, :ok, {topics, refs}}
    else
      {:reply, :error, {topics, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {topics, refs}) do
    {topic, refs} = Map.pop(refs, ref)
    topics = Map.delete(topics, topic)
    {:noreply, {topics, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Error in TopicRegistry: #{inspect(msg)}")
    {:noreply, state}
  end
end
