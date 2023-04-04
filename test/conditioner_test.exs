defmodule ConditionerTest do
  use ExUnit.Case
  # doctest Conditioner

  defmodule SomeMatcher do
    # use Conditioner.Matcher

    def match(["filename", "contains", str], _original_value) do
      fn val ->
        String.contains?(val, str)
      end
    end
  end

  test "greets the world" do
    conditions = %{
      "and" => [
        ["filename", "contains", "he"],
        ["filename", "contains", "lo"],
        %{
          "or" => [
            ["filename", "contains", "bo"],
            ["filename", "contains", "he"]
          ]
        }
      ]
    }

    result = Conditioner.match?(conditions, "hello", SomeMatcher)

    assert result
  end
end
