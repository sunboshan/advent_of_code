defmodule AOC2016.Day3 do
  @moduledoc """
  Day 3: Squares With Three Sides
  """

  def run1 do
    File.read!("priv/2016/3.txt")
    |> String.split("\n", trim: true)
    |> Enum.count(fn e ->
      String.split(e, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> is_triangle?()
    end)
  end

  def run2 do
    File.read!("priv/2016/3.txt")
    |> String.split("\n", trim: true)
    |> Stream.map(fn e ->
      String.split(e, " ", trim: true)
      |> Stream.map(&String.to_integer/1)
    end)
    |> Stream.zip()
    |> Enum.flat_map(&Tuple.to_list/1)
    |> count(0)
  end

  defp count([], acc), do: acc
  defp count([a, b, c | t], acc) do
    n = if is_triangle?(Enum.sort([a, b, c])), do: 1, else: 0
    count(t, acc + n)
  end

  defp is_triangle?([a, b, c]) when a + b > c, do: true
  defp is_triangle?(_),                        do: false
end
