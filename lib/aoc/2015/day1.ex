defmodule AOC2015.Day1 do
  @moduledoc """
  Day 1: Not Quite Lisp
  """

  def run1 do
    File.read!("priv/2015/1.txt")
    |> String.trim()
    |> count()
  end

  def run2 do
    File.read!("priv/2015/1.txt")
    |> String.trim()
    |> count(0, 0)
  end

  def count(<<>>), do: 0
  def count(<<?(, t::binary>>), do: count(t) + 1
  def count(<<?), t::binary>>), do: count(t) - 1

  def count(_, n, -1), do: n
  def count(<<?(, t::binary>>, n, acc), do: count(t, n + 1, acc + 1)
  def count(<<?), t::binary>>, n, acc), do: count(t, n + 1, acc - 1)
end
