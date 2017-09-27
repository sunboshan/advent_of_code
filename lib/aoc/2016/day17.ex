defmodule AOC2016.Day17 do
  @moduledoc """
  Day 17: Two Steps Forward

  - part 1 use A*, use PQueue module from Day 13
  - part 2 use DFS
  """

  @type loc :: {integer, integer}

  def run1 do
    input = "yjjvjgan"
    shortest(input)
  end

  def run2 do
    input = "yjjvjgan"
    longest(input)
  end

  @doc """
  Find shortest path to target. Use A*.

      iex> AOC2016.Day17.shortest("ihgpwlah")
      "DDRRRD"
      iex> AOC2016.Day17.shortest("ihgpwlah")
      "DDRRRD"
      iex> AOC2016.Day17.shortest("kglvqrro")
      "DDUDRLRRUDRD"
      iex> AOC2016.Day17.shortest("ulqzkmiv")
      "DRURDRUDDLLDLUURRDULRLDUUDDDRR"
  """
  @spec shortest(String.t) :: String.t
  def shortest(input) do
    init = {{0, 0}, 0, input}
    pqueue = PQueue.new()
      |> PQueue.put(init, 0)
    do_shortest(init, {3, 3}, pqueue)
  end

  defp do_shortest({stop, _, passcode}, stop, _) do
    Regex.run(~r/[A-Z]+/, passcode)
    |> hd()
  end
  defp do_shortest({loc, cost, passcode}, stop, pqueue) do
    {_, pqueue} = PQueue.out(pqueue)
    pqueue = Enum.reduce(neighbors(loc, passcode), pqueue, fn {neighbor, path}, acc ->
      priority = cost + heuristic(neighbor, stop)
      PQueue.put(acc, {neighbor, cost + 1, path}, priority)
    end)
    {next, _} = PQueue.peek(pqueue)
    do_shortest(next, stop, pqueue)
  end

  @doc """
  Heuristic function for A*. Use manhattan distance.
  """
  @spec heuristic(loc, loc) :: integer
  def heuristic({x, y}, {i, j}) do
    abs(x - i) + abs(y - j)
  end

  @doc """
  Find the length of longest path to target. Use DFS.

      iex> AOC2016.Day17.longest("ihgpwlah")
      370
      iex> AOC2016.Day17.longest("kglvqrro")
      492
      iex> AOC2016.Day17.longest("ulqzkmiv")
      830
  """
  @spec longest(String.t) :: integer
  def longest(input) do
    init = {{0, 0}, input}
    do_longest([init], {3, 3}, <<>>)
  end

  defp do_longest([], _, longest) do
    byte_size(longest) - 8
  end
  defp do_longest([{stop, passcode} | t], stop, longest) do
    longest = if byte_size(passcode) > byte_size(longest),
      do: passcode,
      else: longest
    do_longest(t, stop, longest)
  end
  defp do_longest([{loc, passcode} | t], stop, longest) do
    t = Enum.reduce(neighbors(loc, passcode), t, &[&1 | &2])
    do_longest(t, stop, longest)
  end

  @doc """
  Return all available neighbors with their path.
  """
  @spec neighbors(loc, String.t) :: [{loc, String.t}]
  def neighbors({x, y}, passcode) do
    {u, d, l, r} = check(:crypto.hash(:md5, passcode))
    [{{x, y - u}, "#{passcode}U"},
     {{x, y + d}, "#{passcode}D"},
     {{x - l, y}, "#{passcode}L"},
     {{x + r, y}, "#{passcode}R"},]
    |> Enum.filter(fn {loc, _} -> valid?(loc, {x, y}) end)
  end

  @doc """
  Check the hash for directions.
  """
  @spec check(binary) :: {integer, integer, integer, integer}
  def check(<<u::4, d::4, l::4, r::4, _::bits>>) do
    {do_check(u), do_check(d), do_check(l), do_check(r)}
  end

  defp do_check(int) when int > 10, do: 1
  defp do_check(_),                 do: 0

  defp valid?({x, y}, {x, y}), do: false
  defp valid?({x, y}, _) when x in 0..3 and y in 0..3, do: true
  defp valid?(_, _), do: false
end
