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

  test "Test subscribe", %{registry: registry} do
    Mq.TopicRegistry.create_topic(registry, "topic1")
    {:ok, topic} = Mq.TopicRegistry.lookup(registry, "topic1")

    Mq.Topic.add(topic, "dummy subscriber")
    assert Mq.Topic.list(topic) == ["dummy subscriber"]
    Mq.Topic.remove(topic, "dummy subscriber")
    assert Mq.Topic.list(topic) == []
  end
end
