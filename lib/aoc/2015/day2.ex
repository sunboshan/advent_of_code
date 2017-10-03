defmodule AOC2015.Day2 do
  @moduledoc """
  Day 2: I Was Told There Would Be No Math
  """

  def run1 do
    File.read!("priv/2015/2.txt")
    |> parse()
    |> Stream.map(&rect/1)
    |> Enum.sum()
  end

  def run2 do
    File.read!("priv/2015/2.txt")
    |> parse()
    |> Stream.map(&ribbon/1)
    |> Enum.sum()
  end

  def parse(input) do
    String.split(input)
    |> Enum.map(&do_parse/1)
  end

  defp do_parse(str) do
    Regex.run(~r/(\d+)x(\d+)x(\d+)/, str, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> List.to_tuple()
  end

  def rect({a, b, c}) do
    2 * a * b + 2 * b * c + 2 * c * a + a * b
  end

  def ribbon({a, b, c}) do
    2 * (a + b) + a * b * c
  end
end
