# Conditioner

## Introduction

Conditioner allows you to define and process conditional logic in separated way:

1. Create logical representation of conditions:

```elixir
conditions = %{
      "and" => [
        ["filename", "containsfn", "he"],
        ["filename", "containsfn", "lo"],
        ["otherrule", "contains", "lo"],
        %{
          "or" => [
            ["filename", "containsfn", "bo"],
            ["filename", "containsfn", "he"],
            %{"and" => true}
          ]
        }
      ]
    }

```

2. Define matcher module with rules:

```elixir
  defmodule SomeMatcher do
    use Conditioner.Matcher

    def match(["filename", "containsfn", str], _original_value) do
      fn val ->
        String.contains?(val, str)
      end
    end

    def match(["otherrule", "contains", str], value) do
      String.contains?(value, str)
    end
  end
```

3. Verify conditions by calling matcher with rules:

```elixir
result = Conditioner.match?(conditions, "hello", SomeMatcher)
```

## Goals

1. Conditions are represented as map, so they can be easily serialized and stored,

2. Rules can be represented as any type, as long as rule can be matched by pattern matching mechanism in Elixir


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `conditioner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:conditioner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/conditioner>.

