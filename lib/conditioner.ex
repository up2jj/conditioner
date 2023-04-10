defmodule Conditioner do
  def match?([], value, matcher) do
    apply(matcher, :match_empty_conditions, [value])
  end

  def match?(conditions, value, matcher) when is_map(conditions) do
    match?([conditions], value, matcher)
  end

  def match?(conditions, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.all?()
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
    call_matcher(rule, value, {m, :match, a})
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
    apply(matcher, :match, [rule, value])
  end

  defp unpack_value(rule, value, acc) when is_function(rule, 1) do
    [rule.(value) | acc]
  end

  defp unpack_value(rule, _value, acc) when is_boolean(rule) do
    [rule | acc]
  end
end
