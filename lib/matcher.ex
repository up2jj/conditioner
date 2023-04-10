defmodule Conditioner.Matcher do
  defmacro __using__(opts) do
    match_empty = Keyword.get(opts, :match_empty, true)

    quote do
      def match(_, _), do: unquote(match_empty)

      def match_empty_or(_branch, _value) do
        false
      end

      def match_empty_and(_branch, _value) do
        false
      end

      defoverridable match: 2, match_empty_and: 2, match_empty_or: 2
    end
  end
end
