defmodule Mq.SupervisorTest do
  use ExUnit.Case, async: true

  test "Check that topic registry is initialized" do
    assert Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "dummy") == :error
  end

  test "Subscribe/Unsubscribe" do
    test_pid = spawn(fn -> 0 end)
    assert Mq.Supervisor.subscribe(test_pid, "topic1") == :ok
    {:ok, topic_pid} = Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "topic1")
    assert Mq.Topic.list(topic_pid) == [test_pid]

    Mq.Supervisor.unsubscribe(test_pid, "topic1")
    assert Mq.Topic.list(topic_pid) == []
  end

  test "Subscribe to existing channel" do
    test_pid_1 = spawn(fn -> 0 end)
    Mq.TopicRegistry.create_topic(Mq.TopicRegistryInstance, "topic2")
    assert Mq.Supervisor.subscribe(test_pid_1, "topic2") == :ok
    {:ok, topic_pid} = Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "topic2")
    assert Mq.Topic.list(topic_pid) == [test_pid_1]
  end
end
