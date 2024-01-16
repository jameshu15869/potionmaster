defmodule Mq do
  @moduledoc """
  Documentation for `Mq`.
  """

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Mq.Supervisor, name: Mq.Supervisor},
      {Task.Supervisor, name: Mq.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Mq.Server.accept(port) end}, restart: :permanent)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mq.TopSupervisor)
  end
end
