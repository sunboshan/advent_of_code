defmodule AOC2015.Day9 do
  @moduledoc """
  Day 9: All in a Single Night

  Just use brute force to calculate every possible permutation.
  """

  def run1 do
    File.read!("priv/2015/9.txt")
    |> parse()
    |> travel()
    |> Enum.min()
  end

  def run2 do
    File.read!("priv/2015/9.txt")
    |> parse()
    |> travel()
    |> Enum.max()
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
    |> Map.new()
  end

  defp do_parse(str) do
    [a, b, c] = Regex.run(~r/(\w+) to (\w+) = (\d+)/, str, capture: :all_but_first)
    [a, b] = Enum.sort([a, b])
    {{a, b}, String.to_integer(c)}
  end

  def travel(map) do
    Map.keys(map)
    |> items([])
    |> permutation()
    |> Stream.map(&distance(&1, map))
  end

  defp items([], acc), do: Enum.uniq(acc)
  defp items([{a, b} | t], acc) do
    items(t, [a, b | acc])
  end

  def permutation([a]), do: [[a]]
  def permutation(list) do
    for a <- list, b <- permutation(list -- [a]), do: [a | b]
  end

  def distance(list, map) do
    do_distance(list, map, 0)
  end

  defp do_distance([_], _, acc), do: acc
  defp do_distance([a, b | t], map, acc) do
    key = Enum.sort([a, b])
      |> List.to_tuple()
    do_distance([b | t], map, Map.get(map, key) + acc)
  end
end
