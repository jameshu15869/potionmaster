defmodule Mq.ClientTest do
  use ExUnit.Case

  setup do
    Application.stop(:mq)
    :ok = Application.start(:mq)
  end

  test "Sanity Test" do
    Mq.TopicRegistry.create_topic(Mq.TopicRegistryInstance, "topic1")
    assert Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "topic1") != nil

    {:ok, client_pid} = Mq.Client.start_link(fn {:topic_message, _, msg} -> IO.puts(msg) end, [])
    {:ok, topic_pid} = Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "topic1")
    Mq.Topic.add(topic_pid, client_pid)
    Mq.TopicRegistry.publish(Mq.TopicRegistryInstance, "topic1", "hello")
  end
end
