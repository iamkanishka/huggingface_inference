defmodule HuggingfaceInferenceTest do
  use ExUnit.Case
  doctest HuggingfaceInference

  test "greets the world" do
    assert HuggingfaceInference.hello() == :world
  end
end
