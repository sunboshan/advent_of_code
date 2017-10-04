defmodule AOC2015.Day5 do
  @moduledoc """
  Day 5: Doesn't He Have Intern-Elves For This?
  """

  def run1 do
    File.read!("priv/2015/5.txt")
    |> String.split()
    |> Stream.map(&check/1)
    |> Enum.count(&(&1))
  end

  def run2 do
    File.read!("priv/2015/5.txt")
    |> String.split()
    |> Stream.map(&check2/1)
    |> Enum.count(&(&1))
  end

  def check(str) do
    do_check(str, 0)
  end

  defp do_check(str, 0) do
    if Regex.match?(~r/ab|cd|pq|xy/, str),
      do: false, else: do_check(str, 1)
  end
  defp do_check(str, 1) do
    case Regex.scan(~r/[aeiou]/, str) do
      list when length(list) >= 3 ->
        do_check(str, 2)
      _ ->
        false
    end
  end
  defp do_check(str, 2) do
    if Regex.match?(~r/(.)\1/, str),
      do: true, else: false
  end

  def check2(str) do
    do_check2(str, 0)
  end

  defp do_check2(str, 0) do
    if Regex.match?(~r/(..).*\1/, str),
      do: do_check2(str, 1), else: false
  end
  defp do_check2(str, 1) do
    if Regex.match?(~r/(.).\1/, str),
      do: true, else: false
  end
end
