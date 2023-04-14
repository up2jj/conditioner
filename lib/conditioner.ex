defmodule Conditioner do
  @moduledoc """

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

    def match?(["filename", "containsfn", str], _original_value) do
      fn val ->
        String.contains?(val, str)
      end
    end

    def match?(["otherrule", "contains", str], value) do
      String.contains?(value, str)
    end
  end
  ```

  3. Verify conditions by calling matcher with rules:

  ```elixir
  result = Conditioner.match?(conditions, "hello", SomeMatcher)
  ```

  """
  def match?([], value, matcher) do
    apply(matcher, :match_empty_conditions, [value])
  end

  @spec match?(map(), any(), any()) :: boolean()
  def match?(conditions, value, matcher) when is_map(conditions) do
    match?([conditions], value, matcher)
  end

  @spec match?(list(), any(), any()) :: boolean()
  def match?(conditions, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.all?()
  end

  defp parse_condition(%{"and" => val}, _value, _matcher) when is_boolean(val) do
    val
  end

  defp parse_condition(%{"or" => val}, _value, _matcher) when is_boolean(val) do
    val
  end

  defp parse_condition(%{"and" => []} = branch, value, matcher) do
    apply(matcher, :match_empty_and, [branch, value])
  end

  defp parse_condition(%{"or" => []} = branch, value, matcher) do
    apply(matcher, :match_empty_or, [branch, value])
  end

  defp parse_condition(%{"and" => conditions}, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.reduce([], &unpack_value(&1, value, &2))
    |> Enum.all?()
  end

  defp parse_condition(%{"or" => conditions}, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.reduce([], &unpack_value(&1, value, &2))
    |> Enum.any?()
  end

  defp parse_condition(rule, _value, _matcher) when is_boolean(rule) do
    rule
  end

  defp parse_condition(rule, value, matcher) do
    call_matcher(rule, value, matcher)
  end

  defp call_matcher(rule, value, {m, a}) do
    call_matcher(rule, value, {m, :match?, a})
  end

  defp call_matcher(rule, value, {m, f, a}) do
    args = List.wrap(a) ++ [rule, value]

    if function_exported?(m, f, Enum.count(args)) do
      apply(m, f, args)
    else
      raise("Matcher module is invalid")
    end
  end

  defp call_matcher(rule, value, matcher) do
    apply(matcher, :match?, [rule, value])
  end

  defp unpack_value(rule, value, acc) when is_function(rule, 1) do
    [rule.(value) | acc]
  end

  defp unpack_value(rule, _value, acc) when is_boolean(rule) do
    [rule | acc]
  end
end
