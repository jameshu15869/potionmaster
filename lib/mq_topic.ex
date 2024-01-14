defmodule Mq.Topic do
  @moduledoc """
  Represents a single topic with a list of subscribers.
  """
  use Agent, restart: :temporary

  @doc """
  Starts a new Mq topic with an empty array.
  """
  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  @doc """
  Gets all the subscribers of a topic.
  """
  def list(topic) do
    Agent.get(topic, fn state -> state end)
  end

  @doc """
  Adds a subscriber to the specified topic.
  """
  def add(topic, subscriber) do
    Agent.update(topic, &[subscriber | &1])
  end

  @doc """
  Removes a subscriber from the specified topic.
  """
  def remove(topic, subscriber) do
    Agent.update(topic, &Enum.filter(&1, fn x -> x != subscriber end))
  end
end
