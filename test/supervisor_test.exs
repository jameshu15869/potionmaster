defmodule Mq.SupervisorTest do
  use ExUnit.Case, async: true

  test "Check that topic registry is initialized" do
    assert Mq.TopicRegistry.lookup(Mq.TopicRegistryInstance, "dummy") == :error
  end
end
