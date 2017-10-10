defmodule AOC2015.Day15 do
  @moduledoc """
  Day 15: Science for Hungry People
  """

  def run1 do
    for a <- 1..100, b <- 1..100, c <- 1..100, d <- 1..100, a + b + c + d == 100 do
      aa = max(a * 2, 0)
      bb = max(b * 5 - d, 0)
      cc = max(a * -2 - b * 3 + c * 5, 0)
      dd = max(c * -1 + d * 5, 0)
      aa * bb * cc * dd
    end
    |> Enum.max()
  end

  def run2 do
    for a <- 1..100, b <- 1..100, c <- 1..100, d <- 1..100, a + b + c + d == 100, 3 * a + 3 * b + 8 * c + 8 * d == 500 do
      aa = max(a * 2, 0)
      bb = max(b * 5 - d, 0)
      cc = max(a * -2 - b * 3 + c * 5, 0)
      dd = max(c * -1 + d * 5, 0)
      aa * bb * cc * dd
    end
    |> Enum.max()
  end
end
