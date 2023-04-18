# Conditioner

[![hex.pm version](https://img.shields.io/hexpm/v/conditioner?color=green)](https://hex.pm/packages/conditioner)

---

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
    # using Conditioner.Matcher is optional, but module provides some convenient functions
    use Conditioner.Matcher

    def match?(["filename", "containsfn", str], _original_value) do
      # match?/2 can return anonymous function or boolean value 
      fn val ->
        String.contains?(val, str)
      end
    end

    def match?(["otherrule", "contains", str], _original_value) do
      String.contains?(value, str)
    end

    def match?("hello", "hello") do
      # rule pattern can by anything, i.e. plain string
      true
    end
  end
```

3. Verify conditions by calling matcher with rules:

```elixir
result = Conditioner.match?(conditions, "hello", SomeMatcher)
```

## Goals

1. Conditions are represented as map, so they can be easily serialized and stored,

2. Rules can be represented as any type, as long as rule can be matched by pattern matching mechanism in Elixir,

3. Matcher can be defined as module or anonymous function.

## Changelog

* 0.2.2 - docs improvements, add custom caller exception, 

* 0.2.1 - support defining matcher as fun with arity 2,

* 0.2.0 - changed `Conditioner.Matcher.match/3` function signature to `match?/3`, docs improvements,

* 0.1.0 - initial version.


## Installation


```elixir
def deps do
  [
    {:conditioner, "~> 0.2.2"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/conditioner>.

