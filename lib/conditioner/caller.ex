defmodule Conditioner.Caller do
  defmodule CallException do
    defexception [:message]
  end

  def call_matcher(rule, value, fun) when is_function(fun, 2) do
    fun.(rule, value)
  end

  def call_matcher(rule, value, {m, a}) do
    call_matcher(rule, value, {m, :match?, a})
  end

  def call_matcher(rule, value, {m, f, a}) do
    args = List.wrap(a) ++ [rule, value]
    count = Enum.count(args)

    if function_exported?(m, f, count) do
      apply(m, f, args)
    else
      raise CallException, "Matcher module is invalid, expected #{f}/#{count} function"
    end
  end

  def call_matcher(rule, value, matcher) do
    apply(matcher, :match?, [rule, value])
  end
end
