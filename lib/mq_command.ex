defmodule Mq.Command do
  @moduledoc"""
  `Mq.Command` is responsible for parsing user input and sending the correct commands to the Mq's topics.
  """

  @doc """
  Parses a string-encoded json (`line`) into a command tuple (:subscribe, :unsubscribe, or :publish).

  Returns {:error, `message`} if an error occurs.
  """
  def parse(line) do
    case Jason.decode(line) do
      {:ok, response_json} ->
        case response_json do
          %{"action" => "subscribe", "topic" => topic} ->
            {:ok, {:subscribe, topic}}

          %{"action" => "unsubscribe", "topic" => topic} ->
            {:ok, {:unsubscribe, topic}}

          %{"action" => "publish", "topic" => topic, "message" => message} ->
            {:ok, {:publish, topic, message}}

          _ ->
            {:error, :unknown_command}
        end

      _ ->
        {:error, :bad_json_format}
    end
  end

  @doc """
  Runs a specified command using a multiclause function.

  `pid` is the process id of the listener thread, which will receive messages from publishing using "send()"
  """
  def run(command, client_pid)

  def run({:subscribe, topic_name}, client_pid) do
    lookup_helper(topic_name, fn topic_pid ->
      Mq.Topic.add(topic_pid, client_pid)
      {:ok, "OK"}
    end)
  end

  def run({:unsubscribe, topic_name}, client_pid) do
    lookup_helper(topic_name, fn topic_pid ->
      Mq.Topic.remove(topic_pid, client_pid)
      {:ok, "OK"}
    end)
  end

  def run({:publish, topic_name, message}, _client_pid) do
    lookup_helper(topic_name, fn topic_pid ->
      Mq.Topic.publish_message(topic_pid, message)
      {:ok, "OK"}
    end)
  end

  defp lookup_helper(topic_name, callback) do
    case Mq.TopicRegistry.create_topic(Mq.TopicRegistryInstance, topic_name) do
      :error -> {:error, :not_found}
      pid -> callback.(pid)
    end
  end
end
