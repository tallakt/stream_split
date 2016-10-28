# StreamSplit

Split a stream into a head and tail, or peek at the first `n` items in a
stream. Both without iterating the tail of the enumerable.

## Docs

[http://hexdocs.pm/stream_split/]

## Usage

```elixir
      iex> {head, tail} = StreamSplit.take_and_drop(Stream.cycle(1..3), 4)
      iex> head
      [1, 2, 3, 1]
      iex> Enum.take(tail, 7)
      [2, 3, 1, 2, 3, 1, 2]
```

```elixir
      iex> {head, new_enum} = StreamSplit.peek(Stream.cycle(1..3), 4)
      iex> head
      [1, 2, 3, 1]
      iex> Enum.take(new_enum, 7)
      [1, 2, 3, 1, 2, 3, 1]
```

## Installation

The package can be installed as:

  1. Add `stream_split` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:stream_split, "~> 0.1.0"}]
    end
    ```

