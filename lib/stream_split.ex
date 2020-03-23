defmodule StreamSplit do
  @enforce_keys [:continuation, :stream]
  defstruct @enforce_keys

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
  @spec take_and_drop(Enumerable.t(), pos_integer) :: {List.t(), Enumerable.t()}
  def take_and_drop(enum, n) when n > 0 do
    case apply_reduce(enum, n) do
      {:done, {_, list}} ->
        {:lists.reverse(list), []}

      {:suspended, {_, list}, cont} ->
        stream_split = %__MODULE__{continuation: cont, stream: continuation_to_stream(cont)}
        {:lists.reverse(list), stream_split}

      {:halted, {_, list}} ->
        {list, []}
    end
  end

  def take_and_drop(enum, 0) do
    {[], enum}
  end

  defp apply_reduce(%__MODULE__{continuation: cont}, n) do
    cont.({:cont, {n, []}})
  end

  defp apply_reduce(enum, n) do
    Enumerable.reduce(enum, {:cont, {n, []}}, &reducer_helper/2)
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
    wrapped = fn {_, _, acc_cont} ->
      case acc_cont.({:cont, :tail}) do
        acc = {:suspended, item, _cont} ->
          {[item], acc}

        {:done, acc} ->
          {:halt, acc}
      end
    end

    cleanup = fn
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
  @spec peek(Enumerable.t(), pos_integer) :: {List.t(), Enumerable.t()}
  def peek(enum, n) when n >= 0 do
    {h, t} = take_and_drop(enum, n)
    {h, Stream.concat(h, t)}
  end

  @doc """
  This function may be seen as splitting head and tail for a `List`, but for
  enumerables.

  It is implemented on top of `take_and_drop/2`

  ## Examples
      iex> {head, tail} = pop(Stream.cycle(1..3))
      iex> head
      1
      iex> Enum.take(tail, 7)
      [2, 3, 1, 2, 3, 1, 2]
  """
  @spec pop(Enumerable.t()) :: {any, Enumerable.t()}
  def pop(enum) do
    {[h], rest} = take_and_drop(enum, 1)
    {h, rest}
  end
end

defimpl Enumerable, for: StreamSplit do
  def count(_stream_split), do: {:error, __MODULE__}

  def member?(_stream_split, _value), do: {:error, __MODULE__}

  def slice(_stream_split), do: {:error, __MODULE__}

  def reduce(%StreamSplit{stream: stream}, acc, fun) do
    Enumerable.reduce(stream, acc, fun)
  end
end
