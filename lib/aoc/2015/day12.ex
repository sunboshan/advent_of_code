defmodule AOC2015.Day12 do
  @moduledoc """
  Day 12: JSAbacusFramework.io

  - part1 is simple enough to use regex
  - part2 needs to use Poison library and work with JSON
  """

  def run1 do
    File.read!("priv/2015/12.txt")
    |> count()
  end

  def run2 do
    File.read!("priv/2015/12.txt")
    |> Poison.decode!()
    |> count()
  end

  def count(input) when is_binary(input) do
    Regex.scan(~r/-?\d+/, input)
    |> Stream.map(fn [e] -> String.to_integer(e) end)
    |> Enum.sum()
  end

  def count(input) do
    do_count(input, 0)
  end

  defp do_count(map, acc) when is_map(map) do
    v = Map.values(map)
    if "red" in v,
      do: acc,
      else: Enum.reduce(v, acc, &do_count/2)
  end
  defp do_count(list, acc) when is_list(list) do
    Enum.reduce(list, acc, &do_count/2)
  end
  defp do_count(int, acc) when is_integer(int) do
    acc + int
  end
  defp do_count(_, acc) do
    acc
  end
end
