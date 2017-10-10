defmodule AOC2015.Day17 do
  @moduledoc """
  Day 17: No Such Thing as Too Much

  Just use brute force, only 2^20 = 1_048_576 combinations.
  """

  def run1 do
    for a1 <- [43, 0],
      a2   <- [3, 0],
      a3   <- [4, 0],
      a4   <- [10, 0],
      a5   <- [21, 0],
      a6   <- [44, 0],
      a7   <- [4, 0],
      a8   <- [6, 0],
      a9   <- [47, 0],
      a10  <- [41, 0],
      a11  <- [34, 0],
      a12  <- [17, 0],
      a13  <- [17, 0],
      a14  <- [44, 0],
      a15  <- [36, 0],
      a16  <- [31, 0],
      a17  <- [46, 0],
      a18  <- [9, 0],
      a19  <- [27, 0],
      a20  <- [38, 0],
      a1 + a2 + a3 + a4 + a5 + a6+ a7+ a8+ a9+ a10+ a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 == 150 do
      [a1 , a2 , a3 , a4 , a5 , a6, a7, a8, a9, a10, a11 , a12 , a13 , a14 , a15 , a16 , a17 , a18 , a19 , a20]
      end
    |> length()
  end

  def run2 do
    list = for a1 <- [43, 0],
      a2   <- [3, 0],
      a3   <- [4, 0],
      a4   <- [10, 0],
      a5   <- [21, 0],
      a6   <- [44, 0],
      a7   <- [4, 0],
      a8   <- [6, 0],
      a9   <- [47, 0],
      a10  <- [41, 0],
      a11  <- [34, 0],
      a12  <- [17, 0],
      a13  <- [17, 0],
      a14  <- [44, 0],
      a15  <- [36, 0],
      a16  <- [31, 0],
      a17  <- [46, 0],
      a18  <- [9, 0],
      a19  <- [27, 0],
      a20  <- [38, 0],
      a1 + a2 + a3 + a4 + a5 + a6+ a7+ a8+ a9+ a10+ a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 == 150 do
      [a1 , a2 , a3 , a4 , a5 , a6, a7, a8, a9, a10, a11 , a12 , a13 , a14 , a15 , a16 , a17 , a18 , a19 , a20]
      end
      |> Enum.map(&Enum.count(&1, fn e -> e != 0 end))
    min = Enum.min(list)
    Enum.count(list, &(&1 == min))
  end
end
