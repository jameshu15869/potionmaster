defmodule Mq.TopicRegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Mq.TopicRegistry)
    %{registry: registry}
  end

  test "Verify registry creation", %{registry: registry} do
    assert Mq.TopicRegistry.lookup(registry, "missing") == :error
  end

  test "Add topics", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    assert {:ok, pid} = Mq.TopicRegistry.lookup(registry, "topic1")
    assert Mq.Topic.list(pid) == []
  end

  test "Remove topics", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    assert {:ok, _} = Mq.TopicRegistry.lookup(registry, "topic1")
    Mq.TopicRegistry.remove_topic(registry, "topic1")
    assert Mq.TopicRegistry.lookup(registry, "topic1") == :error
  end

  test "Test subscribe", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    {:ok, topic} = Mq.TopicRegistry.lookup(registry, "topic1")

    Mq.Topic.add(topic, "dummy subscriber")
    assert Mq.Topic.list(topic) == ["dummy subscriber"]
    Mq.Topic.remove(topic, "dummy subscriber")
    assert Mq.Topic.list(topic) == []
  end

  test "Remove topics on normal exit", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    {:ok, topic} = Mq.TopicRegistry.lookup(registry, "topic1")

    Agent.stop(topic)
    assert Mq.TopicRegistry.lookup(registry, "topic1") == :error
  end

  test "Remove topics on crashes", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    {:ok, topic} = Mq.TopicRegistry.lookup(registry, "topic1")

    Agent.stop(topic, :shutdown)
    assert Mq.TopicRegistry.lookup(registry, "topic1") == :error
  end
end
