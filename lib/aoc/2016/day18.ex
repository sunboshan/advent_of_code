defmodule AOC2016.Day18 do
  @moduledoc """
  Day 18: Like a Rogue

  We use 0 to represent safe `.` and 1 to represent trap `^`.

  Since counting number of 1s for a given integer is O(N), it takes about 1.4s
  to run part 2.
  """

  import Bitwise

  def run0 do
    input = ".^^.^.^^^^"
    rows = 10
    safe(input, rows)
  end

  def run1 do
    input = ".^^^.^.^^^^^..^^^..^..^..^^..^.^.^.^^.^^....^.^...^.^^.^^.^^..^^..^.^..^^^.^^...^...^^....^^.^^^^^^^"
    rows = 40
    safe(input, rows)
  end

  def run2 do
    input = ".^^^.^.^^^^^..^^^..^..^..^^..^.^.^.^^.^^....^.^...^.^^.^^.^^..^^..^.^..^^^.^^...^...^^....^^.^^^^^^^"
    rows = 400_000
    safe(input, rows)
  end

  @doc """
  Count number of 0s for a given input.
  """
  @spec safe(String.t, integer) :: integer
  def safe(input, rows) do
    mask = (1 <<< byte_size(input)) - 1
    {_, n} = Enum.reduce(1..rows, {parse(input), 0}, fn _, {row, acc} ->
      {next(row, mask), acc + count(row)}
    end)
    rows * byte_size(input) - n
  end

  @doc """
  Parse the input to integer, where 0 represent `.`, and 1 represent `^`.
  """
  @spec parse(String.t) :: integer
  def parse(input) do
    do_parse(input, 0)
  end

  defp do_parse(<<>>, acc), do: acc
  defp do_parse(<<?., t::binary>>, acc), do: do_parse(t, (acc <<< 1) + 0)
  defp do_parse(<<?^, t::binary>>, acc), do: do_parse(t, (acc <<< 1) + 1)

  @doc """
  Calculate next row in O(1).

  The original rule is:

      110 -> 1
      011 -> 1
      100 -> 1
      001 -> 1
       _  -> 0

  which can be reduced to this:

      1_0 -> 1
      0_1 -> 1
      0_0 -> 0
      1_1 -> 0

  which is xor for every other bits.

  For example:

           v v
       0110101111    # 1 xor 1, we get 0
            ^
            v
        011010111    # right shift 1 bit
      01101011110    # left shift 1 bit
      01110001001    # xor
            ^
       1111111111    # take a mask that is same length
       1110001001    # next row

  Hence, we can calculate next row in O(1).
  """
  @spec next(integer, integer) :: integer
  def next(int, mask) do
    ((int <<< 1) ^^^ (int >>> 1)) &&& mask
  end

  @doc """
  Count number of 1s in any integer in O(N).
  """
  @spec count(integer) :: integer
  def count(int) do
    do_count(int, 0)
  end

  defp do_count(0, acc), do: acc
  defp do_count(n, acc), do: do_count(n >>> 1, acc + (n &&& 1))
end
