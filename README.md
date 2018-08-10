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

## Docs

The docs for this project are available on [hexdocs][1].

[0]: https://elixirconf.com/2018/speakers/aaron-renner
[1]: https://hexdocs.pm/constantizer
