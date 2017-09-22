defmodule AOC2016.Day15 do
  @moduledoc """
  Day 15: Timing is Everything
  """

  @doc """
  Disc #1 has 5 positions; at time=0, it is at position 4.
  Disc #2 has 2 positions; at time=0, it is at position 1.
  """
  def run0 do
    [{5, 4}, {2, 1}]
    |> find()
  end

  @doc """
  Disc #1 has 13 positions; at time=0, it is at position 10.
  Disc #2 has 17 positions; at time=0, it is at position 15.
  Disc #3 has 19 positions; at time=0, it is at position 17.
  Disc #4 has 7 positions; at time=0, it is at position 1.
  Disc #5 has 5 positions; at time=0, it is at position 0.
  Disc #6 has 3 positions; at time=0, it is at position 1.
  """
  def run1 do
    [{13, 10}, {17, 15}, {19, 17}, {7, 1}, {5, 0}, {3, 1}]
    |> find()
  end

  @doc """
  Disc #7 has 11 positions; at time=0, it is at position 0.
  """
  def run2 do
    [{13, 10}, {17, 15}, {19, 17}, {7, 1}, {5, 0}, {3, 1}, {11, 0}]
    |> find()
  end

  @doc """
  Find the first time the capsule pass.
  """
  @spec find(list) :: integer
  def find(setting) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(&pass?(setting, &1 + 1))
  end

  @doc """
  Check for a given setting, if the capsule will pass through successful.
  """
  @spec pass?(list, integer) :: boolean
  def pass?([], _), do: true
  def pass?([{p, i} | t], n) when rem(i + n, p) == 0, do: pass?(t, n + 1)
  def pass?(_, _), do: false
end
