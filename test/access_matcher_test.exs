defmodule AccessMatcherTest do
  use ExUnit.Case
  alias Conditioner.Matchers.AccessMatcher

  test "handles nested structure" do
    conditions = [
      %{
        "and" => [
          "some.nested.condition",
          "some.even.deeper.nested.condition"
        ]
      }
    ]

    Code.ensure_compiled!(AccessMatcher)

    matcher =
      {AccessMatcher,
       %{
         "some" => %{
           "nested" => %{"condition" => true},
           "even" => %{"deeper" => %{"nested" => %{"condition" => false}}}
         }
       }}

    result = Conditioner.match?(conditions, nil, matcher)

    refute result
  end
end
