defmodule AOC2015.Day8 do
  @moduledoc """
  Day 8: Matchsticks
  """

  def run1 do
    File.read!("priv/2015/8.txt")
    |> String.split()
    |> Stream.map(&count/1)
    |> Enum.reduce(0, fn {n, m}, acc ->
      acc + n - m
    end)
  end

  def run2 do
    File.read!("priv/2015/8.txt")
    |> String.split()
    |> Stream.map(&count2/1)
    |> Enum.reduce(0, fn {n, m}, acc ->
      acc + n - m
    end)
  end

  def count(str) do
    do_count(str, 0, 0)
  end

  defp do_count(<<>>, n, m),                         do: {n, m}
  defp do_count(<<?\\, ?", t::binary>>, n, m),       do: do_count(t, n + 2, m + 1)
  defp do_count(<<?\\, ?\\, t::binary>>, n, m),      do: do_count(t, n + 2, m + 1)
  defp do_count(<<?\\, ?x, _, _, t::binary>>, n, m), do: do_count(t, n + 4, m + 1)
  defp do_count(<<?", t::binary>>, n, m),            do: do_count(t, n + 1, m)
  defp do_count(<<_, t::binary>>, n, m),             do: do_count(t, n + 1, m + 1)

  def count2(str) do
    do_count2(str, 0, 0)
  end

  defp do_count2(<<>>, n, m),                         do: {n, m}
  defp do_count2(<<?\\, ?", t::binary>>, n, m),       do: do_count2(t, n + 4, m + 2)
  defp do_count2(<<?\\, ?\\, t::binary>>, n, m),      do: do_count2(t, n + 4, m + 2)
  defp do_count2(<<?\\, ?x, _, _, t::binary>>, n, m), do: do_count2(t, n + 5, m + 4)
  defp do_count2(<<?", t::binary>>, n, m),            do: do_count2(t, n + 3, m + 1)
  defp do_count2(<<_, t::binary>>, n, m),             do: do_count2(t, n + 1, m + 1)
end
