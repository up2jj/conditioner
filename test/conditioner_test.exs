defmodule ConditionerTest do
  use ExUnit.Case
  # doctest Conditioner

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

  defmodule MatcherWithContext do
    def match(%{raise: "lo"}, ["rule", "contains", _str], _value) do
      raise "woof!"
    end

    def match(_ctx, ["rule", "contains", str], value) do
      String.contains?(value, str)
    end
  end

  test "parses basic condition" do
    conditions = %{
      "and" => [
        ["filename", "containsfn", "he"],
        ["filename", "containsfn", "lo"],
        ["otherrule", "contains", "lo"],
        %{
          "or" => [
            ["filename", "containsfn", "bo"],
            ["filename", "containsfn", "he"]
          ]
        }
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)

    assert result
  end

  test "parses rules starting with OR condition" do
    conditions = %{
      "or" => [
        ["filename", "containsfn", "he"],
        ["filename", "containsfn", "lo"],
        ["otherrule", "contains", "lo"],
        %{
          "or" => [
            false,
            ["filename", "containsfn", "he"]
          ]
        }
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)
    assert result
  end

  test "handles mixing rules with plain booleans" do
    conditions = %{
      "and" => [
        ["filename", "containsfn", "he"],
        false,
        ["otherrule", "contains", "lo"],
        %{
          "or" => [
            ["filename", "containsfn", "bo"],
            true
          ]
        }
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)
    refute result
  end

  test "call fallback on empty branches (AND)" do
    conditions = %{
      "and" => [
        ["filename", "containsfn", "he"],
        %{"and" => []}
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)
    refute result
  end

  test "call fallback on empty branches (OR)" do
    conditions = %{
      "and" => [
        ["filename", "containsfn", "he"],
        %{"or" => []}
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)
    refute result
  end

  test "calls matcher module with provided context" do
    conditions = %{
      "and" => [
        ["rule", "contains", "lo"],
        %{
          "or" => [
            ["rule", "contains", "he"]
          ]
        }
      ]
    }

    assert_raise RuntimeError, fn ->
      Conditioner.match?(conditions, "hello", {MatcherWithContext, %{raise: "lo"}})
    end
  end
end
