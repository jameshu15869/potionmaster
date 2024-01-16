defmodule Mq.CommandTest do
  use ExUnit.Case, async: true

  test "Test Basics" do
    assert Mq.Command.parse(~s({"action" : "subscribe", "topic" : "topic1"})) ==
             {:ok, {:subscribe, "topic1"}}

    assert Mq.Command.parse(~s({"action" : "unsubscribe", "topic" : "topic1"})) ==
             {:ok, {:unsubscribe, "topic1"}}

    assert Mq.Command.parse(~s({"action" : "publish", "topic" : "topic1", "message" : "hello!"})) ==
             {:ok, {:publish, "topic1", "hello!"}}
  end

  test "Test Errors" do
    {status, _} = Mq.Command.parse("not json")
    assert status == :error
    assert Mq.Command.parse(~c"{\"key\": \"invalid json\"}") == {:error, :unknown_command}

    assert Mq.Command.parse(~s({"age":44,"name":"Steve Irwin","nationality":"Australian"})) ==
             {:error, :unknown_command}

    assert Mq.Command.parse(
             ~s({"action" : "publish_message", "topic" : "topic1", "message" : "hello!"})
           ) == {:error, :unknown_command}
  end
end
