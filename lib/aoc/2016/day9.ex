defmodule AOC2016.Day9 do
  @moduledoc """
  Day 9: Explosives in Cyberspace
  """

  def run1 do
    File.read!("priv/2016/9.txt")
    |> String.trim()
    |> decompress()
  end

  def run2 do
    File.read!("priv/2016/9.txt")
    |> String.trim()
    |> decompress2()
  end

  @doc """
  Decompress input.

  iex> AOC2016.Day9.decompress("ADVENT")
  6
  iex> AOC2016.Day9.decompress("A(1x5)BC")
  7
  iex> AOC2016.Day9.decompress("(3x3)XYZ")
  9
  iex> AOC2016.Day9.decompress("A(2x2)BCD(2x2)EFG")
  11
  iex> AOC2016.Day9.decompress("(6x1)(1x3)A")
  6
  iex> AOC2016.Day9.decompress("X(8x2)(3x3)ABCY")
  18
  """
  @spec decompress(String.t) :: integer
  def decompress(input) do
    do_decompress(input, 0)
  end

  defp do_decompress(<<>>, acc), do: acc
  defp do_decompress(<<?(, _::binary>> = str, acc) do
    [marker, i, j] = Regex.run(~r/\((\d+)x(\d+)\)/, str)
    i = String.to_integer(i)
    j = String.to_integer(j)
    n = byte_size(marker)
    <<_::binary-size(n), _::binary-size(i), t::binary>> = str
    do_decompress(t, i * j + acc)
  end
  defp do_decompress(<<_, t::binary>>, acc) do
    do_decompress(t, acc + 1)
  end

  @doc """
  Decompress input version 2.

  iex> AOC2016.Day9.decompress2("(3x3)XYZ")
  9
  iex> AOC2016.Day9.decompress2("X(8x2)(3x3)ABCY")
  20
  iex> AOC2016.Day9.decompress2("(27x12)(20x12)(13x14)(7x10)(1x12)A")
  241920
  iex> AOC2016.Day9.decompress2("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")
  445
  """
  @spec decompress2(String.t) :: integer
  def decompress2(input) do
    do_decompress2(input, 0)
  end

  defp do_decompress2(<<>>, acc), do: acc
  defp do_decompress2(<<?(, _::binary>> = str, acc) do
    [marker, i, j] = Regex.run(~r/\((\d+)x(\d+)\)/, str)
    i = String.to_integer(i)
    j = String.to_integer(j)
    n = byte_size(marker)
    <<_::binary-size(n), h::binary-size(i), t::binary>> = str
    do_decompress2(t, decompress2(h) * j + acc)
  end
  defp do_decompress2(<<_, t::binary>>, acc) do
    do_decompress2(t, acc + 1)
  end
end
