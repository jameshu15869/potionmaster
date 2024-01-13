defmodule Mq.Topics do
  @moduledoc """
  Stores mapping from topics to subscribers.
  """

  use Agent

  @doc """
  Starts a new Mq map from topics to subscribers
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end
end
