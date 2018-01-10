defmodule StreamSplitTest do
  use ExUnit.Case
  doctest StreamSplit, import: true

  test "empty stream" do
    stream = Stream.resource(fn -> nil end, fn s -> {:halt, s} end, fn _ -> nil end)
    assert Enum.to_list(stream) == []
    {elements, []} = StreamSplit.take_and_drop(stream, 1)
    assert elements == []
  end
end
