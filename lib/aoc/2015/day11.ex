defmodule AOC2015.Day11 do
  @moduledoc """
  Day 11: Corporate Policy
  """

  def run1 do
    Stream.iterate("hepxcrrq", &next/1)
    |> Enum.find(&valid?/1)
  end

  def run2 do
    Stream.iterate("hepxxzaa", &next/1)
    |> Enum.find(&valid?/1)
  end

  @doc """
  Find the next password, wrap around `z` to `a`.
  """
  @spec next(String.t) :: String.t
  def next(<<>>), do: <<>>
  def next(input) do
    n = byte_size(input) - 1
    case input do
      <<h::binary-size(n), ?z>> ->
        <<next(h)::binary, ?a>>
      <<h::binary-size(n), t>> ->
        <<h::binary, t + 1>>
    end
  end

  @doc """
  Check if password is valid according to rule 1-3.
  """
  @spec valid?(String.t) :: boolean
  def valid?(input) do
    rule1(input, input)
  end

  defp rule1(<<>>, _), do: false
  defp rule1(<<a, b, c, _::binary>>, input) when a + 1 == b and b + 1 == c do
    rule2(input, input)
  end
  defp rule1(<<_, t::binary>>, input), do: rule1(t, input)

  defp rule2(<<>>, input), do: rule3(input, {0, 0})
  defp rule2(<<h, _::binary>>, _) when h in [?i, ?o, ?l], do: false
  defp rule2(<<_, t::binary>>, input), do: rule2(t, input)

  defp rule3(_, {_, 2}), do: true
  defp rule3(<<>>, _), do: false
  defp rule3(<<h, h, t::binary>>, {f, n}) when h != f and n < 2 do
    rule3(t, {h, n + 1})
  end
  defp rule3(<<_, t::binary>>, {f, n}), do: rule3(t, {f, n})
end
