defmodule Conditioner do
  @moduledoc """
  Documentation for `Conditioner`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Conditioner.hello()
      :world

  """
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

  # co jesli pusty and
  # co jesli pusty or
  defp parse_condition(%{"and" => conditions}, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.reduce([], fn
      rule, acc when is_function(rule, 1) ->
        [rule.(value) | acc]

      rule, acc when is_boolean(acc) ->
        [rule | acc]

      _, acc ->
        acc
    end)
    |> Enum.all?()
  end

  defp parse_condition(%{"or" => conditions}, value, matcher) do
    conditions
    |> Enum.map(&parse_condition(&1, value, matcher))
    |> Enum.reduce_while([], fn
      rule, _acc when is_function(rule, 1) ->
        case rule.(value) do
          false -> {:halt, false}
          true -> {:cont, true}
        end

      rule, acc when is_boolean(acc) ->
        case rule do
          false -> {:halt, false}
          true -> {:cont, true}
        end
    end)
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
end
