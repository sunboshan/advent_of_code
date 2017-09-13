defmodule AOC2016.Day2 do
  @moduledoc """
  Day 2: Bathroom Security
  """

  def run1 do
    File.read!("priv/2016/2.txt")
    |> code()
  end

  def run2 do
    File.read!("priv/2016/2.txt")
    |> code2()
  end

  @doc """
  Get the code for given input.

  iex> AOC2016.Day2.code("ULL\\nRRDDD\\nLURDL\\nUUUUD\\n")
  "1985"
  """
  @spec code(String.t) :: String.t
  def code(input) do
    do_code(input, 5, [])
  end

  defp do_code(<<>>, _, acc),               do: Enum.reverse(acc) |> Enum.join()
  defp do_code(<<?\n, t::binary>>, n, acc), do: do_code(t, n, [n | acc])
  defp do_code(<<key, t::binary>>, n, acc), do: do_code(t, move(n, key), acc)

  @doc """
  Get the code from a different keypad.

  iex> AOC2016.Day2.code2("ULL\\nRRDDD\\nLURDL\\nUUUUD\\n")
  "5DB3"
  """
  @spec code2(String.t) :: String.t
  def code2(input) do
    do_code2(input, ?5, [])
  end

  defp do_code2(<<>>, _, acc),               do: Enum.reverse(acc) |> :binary.list_to_bin()
  defp do_code2(<<?\n, t::binary>>, n, acc), do: do_code2(t, n, [n | acc])
  defp do_code2(<<key, t::binary>>, n, acc), do: do_code2(t, move2(n, key), acc)

  defp move(1, ?D), do: 4
  defp move(1, ?R), do: 2
  defp move(2, ?D), do: 5
  defp move(2, ?L), do: 1
  defp move(2, ?R), do: 3
  defp move(3, ?D), do: 6
  defp move(3, ?L), do: 2
  defp move(4, ?U), do: 1
  defp move(4, ?D), do: 7
  defp move(4, ?R), do: 5
  defp move(5, ?U), do: 2
  defp move(5, ?D), do: 8
  defp move(5, ?L), do: 4
  defp move(5, ?R), do: 6
  defp move(6, ?U), do: 3
  defp move(6, ?D), do: 9
  defp move(6, ?L), do: 5
  defp move(7, ?U), do: 4
  defp move(7, ?R), do: 8
  defp move(8, ?U), do: 5
  defp move(8, ?L), do: 7
  defp move(8, ?R), do: 9
  defp move(9, ?U), do: 6
  defp move(9, ?L), do: 8
  defp move(n, _),  do: n

  defp move2(?1, ?D), do: ?3
  defp move2(?2, ?D), do: ?6
  defp move2(?2, ?R), do: ?3
  defp move2(?3, ?U), do: ?1
  defp move2(?3, ?D), do: ?7
  defp move2(?3, ?L), do: ?2
  defp move2(?3, ?R), do: ?4
  defp move2(?4, ?D), do: ?8
  defp move2(?4, ?L), do: ?3
  defp move2(?5, ?R), do: ?6
  defp move2(?6, ?U), do: ?2
  defp move2(?6, ?D), do: ?A
  defp move2(?6, ?L), do: ?5
  defp move2(?6, ?R), do: ?7
  defp move2(?7, ?U), do: ?3
  defp move2(?7, ?D), do: ?B
  defp move2(?7, ?L), do: ?6
  defp move2(?7, ?R), do: ?8
  defp move2(?8, ?U), do: ?4
  defp move2(?8, ?D), do: ?C
  defp move2(?8, ?L), do: ?7
  defp move2(?8, ?R), do: ?9
  defp move2(?9, ?L), do: ?8
  defp move2(?A, ?U), do: ?6
  defp move2(?A, ?R), do: ?B
  defp move2(?B, ?U), do: ?7
  defp move2(?B, ?D), do: ?D
  defp move2(?B, ?L), do: ?A
  defp move2(?B, ?R), do: ?C
  defp move2(?C, ?U), do: ?8
  defp move2(?C, ?L), do: ?B
  defp move2(?D, ?U), do: ?B
  defp move2(n, _),   do: n
end
