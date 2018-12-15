# Depot

Depot is a filesystem abstraction for elixir providing a unified interface over many implementations. It allows you to swap out filesystems on the fly without needing to rewrite all of your application code in the process. It can eliminate vendor-lock in, reduce technical debt, and improve the testability of your code.

This library is based on the ideas of [flysystem](http://flysystem.thephpleague.com/), which is a PHP library providing similar functionality.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `depot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:depot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/depot](https://hexdocs.pm/depot).

