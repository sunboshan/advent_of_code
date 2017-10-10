defmodule AOC2015.Day16 do
  @moduledoc """
  Day 16: Aunt Sue
  """

  @map %{"children" => 3, "cats" => 7, "samoyeds" => 2,
      "pomeranians" => 3, "akitas" => 0, "vizslas" => 0,
      "goldfish" => 5, "trees" => 3, "cars" => 2, "perfumes" => 1}

  def run1 do
    File.read!("priv/2015/16.txt")
    |> String.split("\n", trim: true)
    |> Enum.find(&valid?(@map, &1))
  end

  def run2 do
    File.read!("priv/2015/16.txt")
    |> String.split("\n", trim: true)
    |> Enum.find(&valid2?(@map, &1))
  end

  def valid?(map, str) do
    [a, x, b, y, c, z] = Regex.run(~r/^Sue \d+: (\w+): (\d+), (\w+): (\d+), (\w+): (\d+)/, str, capture: :all_but_first)
    map[a] == String.to_integer(x) and map[b] == String.to_integer(y) and map[c] == String.to_integer(z)
  end

  def valid2?(map, str) do
    [a, x, b, y, c, z] = Regex.run(~r/^Sue \d+: (\w+): (\d+), (\w+): (\d+), (\w+): (\d+)/, str, capture: :all_but_first)
    check(map, a, String.to_integer(x)) and check(map, b, String.to_integer(y)) and check(map, c, String.to_integer(z))
  end

  defp check(map, "cats", n),        do: n > map["cats"]
  defp check(map, "trees", n),       do: n > map["trees"]
  defp check(map, "pomeranians", n), do: n < map["pomeranians"]
  defp check(map, "goldfish", n),    do: n < map["goldfish"]
  defp check(map, rest, n),          do: n == map[rest]
end
