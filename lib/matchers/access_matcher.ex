defmodule Conditioner.Matchers.AccessMatcher do
  def match(rules, rule, value) when is_binary(rule) do
    rule = String.split(rule, ".")

    match(rules, rule, value)
  end

  def match(rules, rule, _value) do
    parse(rules, rule)
  end

  defp parse(rules, rule) do
    case get_in(rules, rule) do
      nil -> false
      result -> result
    end
  end
end
