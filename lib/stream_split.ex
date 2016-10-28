defmodule StreamSplit do
  @doc """
  This function is a combination of `Enum.take/2` and `Enum.drop/2` returning
  first `n` dropped elements and the rest of the enum as a stream.

  The important difference is that the enumerable is only iterated once, and
  only for the required `n` items. The rest of the enumerable may be iterated
  lazily later from the returned stream.

  ## Examples
      iex> {head, tail} = take_and_drop(Stream.cycle(1..3), 4)
      iex> head
      [1, 2, 3, 1]
      iex> Enum.take(tail, 7)
      [2, 3, 1, 2, 3, 1, 2]
  """
  @spec take_and_drop(Enumerable.t, pos_integer) :: {List.t, Enumerable.t}
  def take_and_drop(enum, n) when n >= 0 do
    case Enumerable.reduce(enum, {:cont, {n, []}}, &reducer_helper/2) do
      {:done, {_, list}} ->
        {:lists.reverse(list), []}
      {:suspended, {_, list}, cont} ->
        {:lists.reverse(list), continuation_to_stream(cont)}
    end
  end

  defp reducer_helper(item, :tail) do
    {:suspend, item}
  end

  defp reducer_helper(item, {c, list}) when c > 1 do
    {:cont, {c - 1, [item | list]}}
  end

  defp reducer_helper(item, {_, list}) do
    {:suspend, {0, [item | list]}}
  end

  defp continuation_to_stream(cont) do
    wrapped =
      fn {_, _, acc_cont} -> 
        case acc_cont.({:cont, :tail}) do
          acc = {:suspended, item, _cont} ->
            {[item], acc}
          {:done, acc} ->
            {:halt, acc}
        end
      end
    cleanup =
      fn
        {:suspended, _, acc_cont} ->
          acc_cont.({:halt, nil})
        _ ->
          nil
      end
    Stream.resource(fn -> {:suspended, nil, cont} end, wrapped, cleanup)
  end

  @doc """
  This function looks at the first `n` items in a stream. The remainder of the
  enumerable is returned as a stream that may be lazily enumerated at a later
  time.

  You may think of this function as popping `n` items of the enumerable, then
  pushing them back after making a copy.

  Use this function with a stream to peek at items, but not iterate a stream
  with side effects more than once.

  ## Examples
      iex> {head, new_enum} = peek(Stream.cycle(1..3), 4)
      iex> head
      [1, 2, 3, 1]
      iex> Enum.take(new_enum, 7)
      [1, 2, 3, 1, 2, 3, 1]
  """
  @spec peek(Enumerable.t, pos_integer) :: {List.t, Enumerable.t}
  def peek(enum, n) when n > 0 do
    {h, t} = take_and_drop enum, n
    {h, Stream.concat(h, t)}
  end
end
