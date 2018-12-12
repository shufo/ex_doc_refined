defmodule ExDocRefinedTest do
  use ExUnit.Case
  doctest ExDocRefined

  test "greets the world" do
    assert ExDocRefined.hello() == :world
  end
end
