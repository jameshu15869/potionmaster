defmodule Mq.TopicTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, topic} = Mq.Topic.start_link([])
    %{topic: topic}
  end

  test "Store subscribers into topic", %{topic: topic} do
    assert Mq.Topic.list(topic) == []
    Mq.Topic.add(topic, "dummy")
    assert Mq.Topic.list(topic) == ["dummy"]
  end

  test "Remove subscribers from a topic", %{topic: topic} do
    assert Mq.Topic.list(topic) == []
    Mq.Topic.add(topic, "dummy")
    Mq.Topic.add(topic, "dummy1")
    assert Enum.member?(Mq.Topic.list(topic), "dummy")
    assert Enum.member?(Mq.Topic.list(topic), "dummy1")
    Mq.Topic.remove(topic, "dummy1")
    assert Mq.Topic.list(topic) == ["dummy"]
  end
end
