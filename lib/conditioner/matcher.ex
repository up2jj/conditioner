defmodule Conditioner.Matcher do
  @doc """
  Adds bolerplate methods to matcher module. 

  > #### Hint {: .neutral}
  >
  > Using this module is not required. Any plain module can be used as a matcher
  """
  defmacro __using__(opts) do
    match_empty = Keyword.get(opts, :match_empty, true)

    quote do
      def match?(_, _, _), do: unquote(match_empty)

      def match_empty_or(_branch, _value) do
        false
      end

      def match_empty_and(_branch, _value) do
        false
      end

      defoverridable match?: 3, match_empty_and: 2, match_empty_or: 2
    end
  end
end
