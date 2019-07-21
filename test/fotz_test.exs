defmodule FotzTest do
  use ExUnit.Case
  doctest Fotz

  test "greets the world" do
    assert Fotz.hello() == :world
  end
end
