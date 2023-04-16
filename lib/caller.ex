defmodule Conditioner.Caller do
  def call_matcher(rule, value, fun) when is_function(fun, 2) do
    fun.(rule, value)
  end

  def call_matcher(rule, value, {m, a}) do
    call_matcher(rule, value, {m, :match?, a})
  end

  def call_matcher(rule, value, {m, f, a}) do
    args = List.wrap(a) ++ [rule, value]

    if function_exported?(m, f, Enum.count(args)) do
      apply(m, f, args)
    else
      raise("Matcher module is invalid")
    end
  end

  def call_matcher(rule, value, matcher) do
    apply(matcher, :match?, [rule, value])
  end
end
