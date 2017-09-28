defmodule AOC2016.Day21 do
  @moduledoc """
  Day 21: Scrambled Letters and Hash
  """

  def run0 do
    input = "abcde"
    """
    swap position 4 with position 0
    swap letter d with letter b
    reverse positions 0 through 4
    rotate left 1 step
    move position 1 to position 4
    move position 3 to position 0
    rotate based on position of letter b
    rotate based on position of letter d
    """
    |> parse()
    |> scramble(input)
  end

  def run1 do
    input = "abcdefgh"
    File.read!("priv/2016/21.txt")
    |> parse()
    |> scramble(input)
  end

  def run2 do
    input = "fbgdceah"
    File.read!("priv/2016/21.txt")
    |> parse()
    |> parse_r()
    |> scramble(input)
  end

  @doc """
  Parse the input.
  """
  @spec parse(String.t) :: [term]
  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
  end

  defp do_parse(<<"swap position ", i, " with position ", j>>) do
    {i, j} = if i < j, do: {i, j}, else: {j, i}
    {:swap_p, i - ?0, j - ?0}
  end
  defp do_parse(<<"swap letter ", a, " with letter ", b>>) do
    {:swap_l, a, b}
  end
  defp do_parse(<<"reverse positions ", i, " through ", j>>) do
    {i, j} = if i < j, do: {i, j}, else: {j, i}
    {:reverse, i - ?0, j - ?0}
  end
  defp do_parse(<<"rotate left ", n, _::binary>>) do
    {:rotate_l, n - ?0}
  end
  defp do_parse(<<"rotate right ", n, _::binary>>) do
    {:rotate_r, n - ?0}
  end
  defp do_parse(<<"move position ", i, " to position ", j>>) do
    {:move, i - ?0, j - ?0}
  end
  defp do_parse(<<"rotate based on position of letter ", a>>) do
    {:rotate_p, a}
  end

  @doc """
  Reverse the operations list.

  Note the only thing need extra care is `:rotate_p`. We need to pre-calculate
  the rotation table.
  """
  def parse_r(list) do
    Enum.reverse(list)
    |> Enum.map(&do_parse_r/1)
  end

  defp do_parse_r({:rotate_l, n}), do: {:rotate_r, n}
  defp do_parse_r({:rotate_r, n}), do: {:rotate_l, n}
  defp do_parse_r({:move, i, j}),  do: {:move, j, i}
  defp do_parse_r({:rotate_p, a}), do: {:rotate_pr, a}
  defp do_parse_r(ops),            do: ops

  @doc """
  Scramble the input according to the operations list.
  """
  @spec scramble(list, String.t) :: String.t
  def scramble(list, input) do
    Enum.reduce(list, input, &do_scramble/2)
  end

  defp do_scramble({:swap_p, i, j}, str) do
    n = j - i - 1
    <<x::binary-size(i), a, y::binary-size(n), b, z::binary>> = str
    <<x::binary, b, y::binary, a, z::binary>>
  end
  defp do_scramble({:swap_l, a, b}, str) do
    swap(str, a, b)
  end
  defp do_scramble({:reverse, i, j}, str) do
    n = j - i + 1
    <<x::binary-size(i), y::binary-size(n), z::binary>> = str
    <<x::binary, String.reverse(y)::binary, z::binary>>
  end
  defp do_scramble({:rotate_l, n}, str) do
    i = rem(n, byte_size(str))
    <<x::binary-size(i), y::binary>> = str
    <<y::binary, x::binary>>
  end
  defp do_scramble({:rotate_r, n}, str) do
    i = byte_size(str) - rem(n, byte_size(str))
    <<x::binary-size(i), y::binary>> = str
    <<y::binary, x::binary>>
  end
  defp do_scramble({:rotate_p, a}, str) do
    i = index(str, a)
    n = if i >= 4, do: i + 2, else: i + 1
    do_scramble({:rotate_r, n}, str)
  end
  defp do_scramble({:rotate_pr, a}, str) do
    i = index(str, a)
    do_scramble({:rotate_l, rotate_pr(i)}, str)
  end
  defp do_scramble({:move, i, j}, str) when i < j do
    n = j - i
    <<x::binary-size(i), a, y::binary-size(n), z::binary>> = str
    <<x::binary, y::binary, a, z::binary>>
  end
  defp do_scramble({:move, j, i}, str) do
    n = j - i
    <<x::binary-size(i), y::binary-size(n), a, z::binary>> = str
    <<x::binary, a, y::binary, z::binary>>
  end

  defp rotate_pr(0), do: 1
  defp rotate_pr(1), do: 1
  defp rotate_pr(2), do: 6
  defp rotate_pr(3), do: 2
  defp rotate_pr(4), do: 7
  defp rotate_pr(5), do: 3
  defp rotate_pr(6), do: 0
  defp rotate_pr(7), do: 4

  defp swap(<<a, t::binary>>, a, b), do: <<b, swap(t, a, b)::binary>>
  defp swap(<<b, t::binary>>, a, b), do: <<a, swap(t, a, b)::binary>>
  defp swap(<<h, t::binary>>, a, b), do: <<h, swap(t, a, b)::binary>>
  defp swap(<<>>, _, _), do: <<>>

  defp index(<<n, _::binary>>, n), do: 0
  defp index(<<_, t::binary>>, n), do: index(t, n) + 1
end

