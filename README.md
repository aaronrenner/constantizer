# Constantizer

Turn functions into constants at compile-time. Very useful when following the
patterns set forth in the ElixirConf [Growing Applications and Taming
Complexity][0] talk.

## Installation

Just add `constantizer` to your list of dependencies.

```elixir
def deps do
  [{:constantizer, "~> 0.2.0"}]
end
```

## Usage

Constantizer allows you to evaluate a 0-arity function at compile time, instead
of repeatedly evaluating it at runtime. This is very helpful when defining
a public api module with swappable backends.

```elixir
defmodule MyApp do
  import Constantizer

  def register_user(params) do
    backend().register_user(params)
  end

  defconstp backend do
    Application.get_env(:my_app, :backend)
  end
end
```

By default, `defconst` and `defconstp` will define a public or private function,
respectively, with its return value being set to the result of the block as it
exists at compile time.

To allow a constant to be evaluated at runtime (for example, so you can inject a
mock backend in your test environment), modify the following setting in your
config.

```elixir
# config/test.exs

config :constantizer, resolve_at_compile_time: false
```

## Benchmarks

You can run constantizer's benchmarks with the following command.

```
mix run benchmarks/general.exs
```

Here is some sample output from our benchmarks that call the following module

```elixir
defmodule MyModule do
  import Constantizer

  def runtime_lookup do
    Application.get_env(:constantizer, :foo)
  end

  defconst compile_time_lookup do
    Application.get_env(:constantizer, :foo)
  end
end
```

```
Name                          ips        average  deviation         median         99th %
compile_time_lookup       87.43 M      0.0114 μs    ±17.43%      0.0110 μs      0.0130 μs
runtime_lookup             4.62 M        0.22 μs    ±41.15%        0.21 μs        0.40 μs

Comparison:
compile_time_lookup       87.43 M
runtime_lookup             4.62 M - 18.93x slower
```

The compile time lookup using `defconst` is 18x faster than using a normal `def` because `Application.get_env/2` is evaluated at compile time instead of runtime.

## Docs

The docs for this project are available on [hexdocs][1].

[0]: https://elixirconf.com/2018/speakers/aaron-renner
[1]: https://hexdocs.pm/constantizer
