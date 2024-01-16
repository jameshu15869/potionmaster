defmodule Mq.Topic do
  @moduledoc """
  Represents a single topic with a list of subscribers.
  """
  use Agent, restart: :temporary

  @doc """
  Starts a new Mq topic with an empty array.
  """
  def start_link(opts) do
    Agent.start_link(fn -> MapSet.new() end, opts)
  end

  @doc """
  Gets all the subscribers of a topic.
  """
  def list(topic) do
    Agent.get(topic, fn state -> MapSet.to_list(state) end)
  end

  @doc """
  Adds a subscriber to the specified topic.
  """
  def add(topic, subscriber) do
    Agent.update(topic, fn state -> MapSet.put(state, subscriber) end)
  end

  @doc """
  Removes a subscriber from the specified topic.
  """
  def remove(topic, subscriber) do
    Agent.update(topic, &MapSet.delete(&1, subscriber))
  end

  def publish_message(topic, topic_name, message) do
    list(topic) |> Enum.map(fn pid -> send(pid, {:topic_message, topic_name, message}) end)
  end
end
