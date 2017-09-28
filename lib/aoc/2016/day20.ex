defmodule AOC2016.Day20 do
  @moduledoc """
  Day 20: Firewall Rules
  """

  import Bitwise

  def run1 do
    File.read!("priv/2016/20.txt")
    |> parse()
    |> find()
  end

  def run2 do
    File.read!("priv/2016/20.txt")
    |> parse()
    |> count()
  end

  @doc """
  Parse and sort the input.
  """
  @spec parse(String.t) :: [{integer, integer}]
  def parse(input) do
    String.split(input)
    |> Stream.map(fn e ->
      [_, l, h] = Regex.run(~r/(\d+)-(\d+)/, e)
      {String.to_integer(l), String.to_integer(h)}
    end)
    |> Enum.sort()
  end

  @doc """
  Find the lowest unblocked IP.

    - if the lowest number is within the range, update the lowest number
    - if the lowest number is bigger than the high range, then remove the range
    - else means we reached a gap between the ip ranges, the current lowest number
      is the lowest available ip
  """
  @spec find(list) :: integer
  def find(list) do
    do_find(list, 0)
  end

  defp do_find([{l, h} | t], n) when n in l..h do
    do_find(t, h + 1)
  end
  defp do_find([{_, h} | t], n) when n > h do
    do_find(t, n)
  end
  defp do_find(_, n), do: n

  @doc """
  Count the total number of blocked ips.

  Similar algorithm as `find/1`.
  """
  @spec count(list) :: integer
  def count(list) do
    do_count(list, 0, 0)
  end

  defp do_count([], n, acc) do
    (1 <<< 32) - n + acc
  end
  defp do_count([{l, h} | t], n, acc) when n in l..h do
    do_count(t, h + 1, acc)
  end
  defp do_count([{_, h} | t], n, acc) when n > h do
    do_count(t, n, acc)
  end
  defp do_count([{l, h} | t], n, acc) do
    do_count(t, h + 1, l - n + acc)
  end
end
