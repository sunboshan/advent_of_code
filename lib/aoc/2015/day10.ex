defmodule AOC2015.Day10 do
  @moduledoc """
  Day 10: Elves Look, Elves Say
  """

  def run1 do
    Stream.iterate("1113122113", &next/1)
    |> Enum.at(40)
    |> byte_size()
  end

  def run2 do
    Stream.iterate("1113122113", &next/1)
    |> Enum.at(50)
    |> byte_size()
  end

  @doc """
  Find next sequence.
  """
  @spec next(String.t) :: String.t
  def next(<<h, t::binary>>) do
    do_next(t, {h, 1}, <<>>)
  end

  defp do_next(<<>>, {f, c}, acc) do
    <<acc::binary, c + ?0, f>>
  end
  defp do_next(<<h, t::binary>>, {h, c}, acc) do
    do_next(t, {h, c + 1}, acc)
  end
  defp do_next(<<h, t::binary>>, {f, c}, acc) do
    do_next(t, {h, 1}, <<acc::binary, c + ?0, f>>)
  end
end
