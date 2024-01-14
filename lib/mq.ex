defmodule Mq do
  @moduledoc """
  Documentation for `Mq`.
  """

  use Application

  @impl true
  def start(_type, _args) do
    Mq.Supervisor.start_link(name: Mq.Supervisor)
  end
end
