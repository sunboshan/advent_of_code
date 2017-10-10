defmodule AOC2015.Day13 do
  @moduledoc """
  Day 13: Knights of the Dinner Table

  The key is to get the circular permutation from a list.
  """

  def run0 do
    """
    Alice would gain 54 happiness units by sitting next to Bob.
    Alice would lose 79 happiness units by sitting next to Carol.
    Alice would lose 2 happiness units by sitting next to David.
    Bob would gain 83 happiness units by sitting next to Alice.
    Bob would lose 7 happiness units by sitting next to Carol.
    Bob would lose 63 happiness units by sitting next to David.
    Carol would lose 62 happiness units by sitting next to Alice.
    Carol would gain 60 happiness units by sitting next to Bob.
    Carol would gain 55 happiness units by sitting next to David.
    David would gain 46 happiness units by sitting next to Alice.
    David would lose 7 happiness units by sitting next to Bob.
    David would gain 41 happiness units by sitting next to Carol.
    """
    |> parse()
    |> seat()
  end

  def run1 do
    File.read!("priv/2015/13.txt")
    |> parse()
    |> seat()
  end

  def run2 do
    File.read!("priv/2015/13.txt")
    |> parse()
    |> seat2()
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
    |> Map.new()
  end

  defp do_parse(str) do
    [a, x, n, b] = Regex.run(~r/^(\w+) would (\w+) (\d+) .* (\w+).$/, str, capture: :all_but_first)
    n = case x do
      "gain" -> String.to_integer(n)
      "lose" -> -String.to_integer(n)
    end
    {{a, b}, n}
  end

  def seat(map) do
    Map.keys(map)
    |> person([])
    |> circular_permutation()
    |> Stream.map(&happiness(&1, map))
    |> Enum.max()
  end

  def seat2(map) do
    Map.keys(map)
    |> person(["me"])
    |> circular_permutation()
    |> Stream.map(&happiness(&1, map))
    |> Enum.max()
  end

  defp person([], acc), do: Enum.uniq(acc)
  defp person([{a, b} | t], acc) do
    person(t, [a, b | acc])
  end

  @doc """
  Get the circulat permutation from the given list.

  Just insert the new item bwtween any adjacent items.
  """
  @spec circular_permutation(list) :: list
  def circular_permutation(list) do
    for [h | t] <- do_circular_permutation(list) do
      [h | t] ++ [h]
    end
  end

  defp do_circular_permutation(list) when length(list) <= 3 do
    [list]
  end
  defp do_circular_permutation([h | t]) do
    for i <- 1..length(t), list <- do_circular_permutation(t) do
      List.insert_at(list, i, h)
    end
  end

  def happiness(list, map) do
    do_happiness(list, map, 0)
  end

  defp do_happiness([_], _, acc), do: acc
  defp do_happiness([a, b | t], map, acc) do
    acc = Map.get(map, {a, b}, 0) + Map.get(map, {b, a}, 0) + acc
    do_happiness([b | t], map, acc)
  end
end
