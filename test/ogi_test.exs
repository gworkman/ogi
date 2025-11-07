defmodule OgiTest do
  use ExUnit.Case
  doctest Ogi

  test "greets the world" do
    assert Ogi.hello() == :world
  end
end
