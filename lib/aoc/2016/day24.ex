defmodule AOC2016.Day24 do
  @moduledoc """
  Day 24: Air Duct Spelunking

  Use A* to cacluate distance between two locations, then draw the map and
  solve the puzzle by hand.
  """

  @type loc :: {integer, integer}

  def run0 do
    map = """
      ###########
      #0.1.....2#
      #.#######.#
      #4.......3#
      ###########
      """
      |> parse()
    (for {k, v} <- map, !is_atom(v), do: {k, v})
    |> combination()
    |> Enum.reduce(%{}, fn {{a1, t1}, {a2, t2}}, acc ->
      n = move(a1, a2, map)
      Map.put(acc, {t1, t2}, n)
    end)
  end

  def runx do
    map = File.read!("priv/2016/24.txt")
      |> parse()
    (for {k, v} <- map, !is_atom(v), do: {k, v})
    |> combination()
    |> Enum.reduce(%{}, fn {{a1, t1}, {a2, t2}}, acc ->
      n = move(a1, a2, map)
      Map.put(acc, {t1, t2}, n)
    end)
  end

  def run1 do
    30 + 48 + 86 + 148 + 22 + 44 + 34
  end

  def run2 do
    92 + 204 + 34 + 44 + 22 + 190 + 48 + 30
  end

  @doc """
  Parse the input to generate a map.
  """
  @spec parse(String.t) :: map
  def parse(input) do
    String.split(input)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {e, i}, acc ->
      parse(e, i, 0, acc)
    end)
  end

  defp parse(<<>>, _, _, acc), do: acc
  defp parse(<<h, t::binary>>, i, j, acc) do
    parse(t, i, j + 1, Map.put(acc, {i, j}, do_parse(h)))
  end

  defp do_parse(?#), do: false
  defp do_parse(?.), do: true
  defp do_parse(n),  do: <<n>>

  @doc """
  Returns distance from start to stop using A*.
  """
  @spec move(loc, loc, map) :: integer
  def move(start, stop, map) do
    pqueue = PQueue.new()
      |> PQueue.put(start, 0)
    do_move(start, stop, map, pqueue, %{start => 0})
  end

  defp do_move(stop, stop, _, _, costs) do
    costs[stop]
  end
  defp do_move(loc, stop, map, pqueue, costs) do
    {_, pqueue} = PQueue.out(pqueue)
    {pqueue, costs} = Enum.reduce(neighbors(loc, stop, map), {pqueue, costs}, fn
        neighbor, {pqueue, costs} ->
      if Map.get(costs, neighbor) do
        {pqueue, costs}
      else
        cost = costs[loc] + 1
        costs = Map.put(costs, neighbor, cost)
        priority = cost + heuristic(neighbor, stop)
        pqueue = PQueue.put(pqueue, neighbor, priority)
        {pqueue, costs}
      end
    end)
    case pqueue do
      {0, nil} -> 0
      _ ->
        {next, _} = PQueue.peek(pqueue)
        do_move(next, stop, map, pqueue, costs)
    end
  end

  @doc """
  Return all valid neighbors for a given location according to the map.
  """
  @spec neighbors(loc, loc, map) :: [loc]
  def neighbors({x, y}, stop, map) do
    [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
    |> Enum.filter(&Map.get(map, &1) == true or &1 == stop)
  end

  @doc """
  Heuristic function for A*. Use manhattan distance.
  """
  @spec heuristic(loc, loc) :: integer
  def heuristic({x, y}, {i, j}) do
    abs(x - i) + abs(y - j)
  end

  @doc """
  Gives the combination of two for a given list.
  """
  @spec combination(list) :: list
  def combination(list) do
    do_combination(list, [])
  end

  defp do_combination([], acc), do: acc
  defp do_combination([h | t], acc) do
    list = for i <- t, do: {h, i}
    do_combination(t, acc ++ list)
  end
end
