defmodule Mq.Supervisor do
  @moduledoc"""
  `Mq.Supervisor` is responsible for the Topic and TopicRegistry processes. This Supervisor is started as a child of the overall application supervisor.
  """
  use Supervisor

  @doc"""
  Starts a new `Mq.Supervisor` process.
  """
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
end
