defmodule AOC2016.Day22 do
  @moduledoc """
  Day 22: Grid Computing

  - part 2 can either be solved by hand or A*
  """

  @type loc :: {integer, integer}

  def run1 do
    grid = File.read!("priv/2016/22.txt")
      |> parse()
    for {n1, _, u1, _} <- grid, {n2, _, _, a2} <- grid, u1 != 0, n1 != n2, u1 <= a2 do
      {n1, n2}
    end
    |> length()
  end

  def run2 do
    grid = File.read!("priv/2016/22.txt")
      |> parse()
    move({4, 25}, {33, 0}, map(grid), 0)
  end

  @doc """
  Draw the grid.

      0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . G
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . _ . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  """
  def runx do
    File.read!("priv/2016/22.txt")
    |> parse()
    |> draw()
  end

  @doc """
  Parse the input.
  """
  @spec parse(String.t) :: list
  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn e ->
      [x, y, size, used, avail] = Regex.run(
        ~r{x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T}, e, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      {{x, y}, size, used, avail}
    end)
  end

  @doc """
  Move from start to target, then change the new target to its left node,
  until we hit {0, 0}.
  """
  @spec move(loc, loc, map, integer) :: integer
  def move(_, {0, _}, _, acc), do: acc
  def move(start, {x, y}, map, acc) do
    n = search(start, {x - 1, y}, map)
    map = Map.put(map, {x - 1, y}, false)
    move({x, y}, {x - 1, y}, map, acc + n + 1)
  end

  @doc """
  Use A* search to find shortest steps between start to stop.
  """
  @spec search(loc, loc, map) :: integer
  def search(start, stop, map) do
    pqueue = PQueue.new()
      |> PQueue.put(start, 0)
    do_search(start, stop, %{start => 0}, pqueue, map)
  end

  defp do_search(stop, stop, costs, _, _), do: costs[stop]
  defp do_search(node, stop, costs, pqueue, map) do
    {_, pqueue} = PQueue.out(pqueue)
    {costs, pqueue} = Enum.reduce(neighbors(node, map), {costs, pqueue}, fn
        neighbor, {costs, pqueue} ->
      if Map.get(costs, neighbor) do
        {costs, pqueue}
      else
        cost = costs[node] + 1
        costs = Map.put(costs, neighbor, cost)
        priority = cost + heuristic(neighbor, stop)
        pqueue = PQueue.put(pqueue, neighbor, priority)
        {costs, pqueue}
      end
    end)
    {next, _} = PQueue.peek(pqueue)
    do_search(next, stop, costs, pqueue, map)
  end

  @doc """
  Find all valid neighbors for a given node.
  """
  @spec neighbors(loc, map) :: [loc]
  def neighbors({x, y}, map) do
    [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
    |> Enum.filter(&valid?(&1, map))
  end

  defp valid?({x, y} = node, map) when x in 0..33 and y in 0..29, do: map[node]
  defp valid?(_, _), do: false

  @doc """
  Heuristic function used in A*. Use manhattan distance.
  """
  @spec heuristic(loc, loc) :: integer
  def heuristic({x, y}, {i, j}) do
    abs(x - i) + abs(y - j)
  end

  @doc """
  Map indicates the validity of nodes. This is used to find valid neighbors for
  a given node.
  """
  @spec map(list) :: map
  def map(grid) do
    Enum.reduce(grid, %{}, &do_map/2)
  end

  defp do_map({node, size, _, _}, acc) when size > 500 do
    Map.put(acc, node, false)
  end
  defp do_map({node, _, _, _}, acc) do
    Map.put(acc, node, true)
  end

  @doc """
  Draw the map from grid.
  """
  @spec draw(list) :: :ok
  def draw(grid) do
    map = Tuple.duplicate(nil, 34)
      |> Tuple.duplicate(30)
    Enum.reduce(grid, map, fn {{x, y}, _, _, _} = e, acc ->
      put_in(acc, [Access.elem(y), Access.elem(x)], do_draw(e))
    end)
    |> display()
  end

  defp do_draw({_, s, _, _}) when s > 500, do: "#"
  defp do_draw({_, _, 0, _}),              do: "_"
  defp do_draw({{0, 0}, _, _, _}),         do: "0"
  defp do_draw({{33, 0}, _, _, _}),        do: "G"
  defp do_draw(_),                         do: "."

  defp display(map) do
    Tuple.to_list(map)
    |> Enum.map_join("\n", fn row ->
      Tuple.to_list(row)
      |> Enum.join(" ")
    end)
    |> IO.puts()
  end
end
