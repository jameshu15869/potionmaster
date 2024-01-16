defmodule Mq.Topic do
  @moduledoc """
  Represents a single topic with a list of subscribers.
  """
  use Agent, restart: :temporary

  @doc """
  Starts a new Mq topic with an empty array.
  """
  def start_link(name, opts) do
    Agent.start_link(fn -> {name, MapSet.new()} end, opts)
  end

  @doc """
  Gets all the subscribers of a topic.
  """
  def list(topic) do
    Agent.get(topic, fn {_name, subscribers} -> MapSet.to_list(subscribers) end)
  end

  def name(topic) do
    Agent.get(topic, fn {name, _subscribers} -> name end)
  end

  @doc """
  Adds a subscriber to the specified topic.
  """
  def add(topic, subscriber) do
    Agent.update(topic, fn {name, subscribers} -> {name, MapSet.put(subscribers, subscriber)} end)
  end

  @doc """
  Removes a subscriber from the specified topic.
  """
  def remove(topic, subscriber) do
    Agent.update(topic, fn {name, subscribers} ->
      {name, MapSet.delete(subscribers, subscriber)}
    end)
  end

  def publish_message(topic, message) do
    topic_name = name(topic)
    list(topic) |> Enum.map(fn pid -> send(pid, {:topic_message, topic_name, message}) end)
  end
end
