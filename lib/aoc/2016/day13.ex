defmodule AOC2016.Day13 do
  @moduledoc """
  Day 13: A Maze of Twisty Little Cubicles

  - part one use A* search algorithm
  - part two use BFS (A* w/o heuristic function)
  """

  import Bitwise

  @type loc :: {integer, integer}

  def run0 do
    stop = {7, 4}
    num = 10
    path = move(stop, num)
    map({10, 10}, stop, num, path)
    length(path) - 1
  end

  def run1 do
    stop = {31, 39}
    num = 1362
    path = move(stop, num)
    map({40, 40}, stop, num, path)
    length(path) - 1
  end

  def run2 do
    list = move2()
    map({40, 40}, {40, 40}, 1362, list)
    length(list)
  end

  @doc """
  Use A* to find destination.
  """
  @spec move(loc, integer) :: [loc]
  def move(stop, n) do
    init = {1, 1}
    pqueue = PQueue.new()
      |> PQueue.put(init, 0)
    do_move(init, stop, n, pqueue, %{init => 0}, %{})
  end

  defp do_move(stop, stop, _, pqueue, _, from) do
    IO.puts "Found stop point. remaining queue size: #{:gb_trees.size(pqueue)}"
    iterate(from, stop)
  end
  defp do_move(loc, stop, n, pqueue, costs, from) do
    {_, pqueue} = PQueue.out(pqueue)
    {pqueue, costs, from} = Enum.reduce(neighbors(loc, n), {pqueue, costs, from}, fn
        neighbor, {pqueue, costs, from} ->
      if Map.get(costs, neighbor) do
        {pqueue, costs, from}
      else
        cost = costs[loc] + 1
        costs = Map.put(costs, neighbor, cost)
        priority = cost + heuristic(neighbor, stop)
        pqueue = PQueue.put(pqueue, neighbor, priority)
        from = Map.put(from, neighbor, loc)
        {pqueue, costs, from}
      end
    end)
    {next, _} = PQueue.peek(pqueue)
    do_move(next, stop, n, pqueue, costs, from)
  end

  @doc """
  Use BFS(A* w/o heuristic) to find all possible locations that can be
  reached within 50 steps.
  """
  @spec move2() :: integer
  def move2 do
    init = {1, 1}
    pqueue = PQueue.new()
      |> PQueue.put(init, 0)
    do_move2({init, 0}, 1362, pqueue, %{init => 0})
  end

  defp do_move2({_, 51}, _, _, costs) do
    IO.puts "Stop move when reach 51 steps."
    for {k, v} <- costs, v <= 50, do: k
  end
  defp do_move2({loc, _}, n, pqueue, costs) do
    {_, pqueue} = PQueue.out(pqueue)
    {pqueue, costs} = Enum.reduce(neighbors(loc, n), {pqueue, costs}, fn
        neighbor, {pqueue, costs} ->
      if Map.get(costs, neighbor) do
        {pqueue, costs}
      else
        cost = costs[loc] + 1
        costs = Map.put(costs, neighbor, cost)
        pqueue = PQueue.put(pqueue, neighbor, cost)
        {pqueue, costs}
      end
    end)
    do_move2(PQueue.peek(pqueue), n, pqueue, costs)
  end

  @doc """
  Get all valid neighbors of a given location.
  """
  @spec neighbors(loc, integer) :: [loc]
  def neighbors({x, y}, n) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(&valid?(&1, n))
  end

  @doc """
  The heuristic function for A*. Using the manhattan distance.
  """
  @spec heuristic(loc, loc) :: integer
  def heuristic({i, j}, {x, y}) do
    abs(x - i) + abs(y - j)
  end

  @doc """
  Iterate the map to get the route from location to {1, 1}.
  """
  @spec iterate(map, loc) :: [loc]
  def iterate(_, {1, 1}), do: [{1, 1}]
  def iterate(map, loc),  do: [loc | iterate(map, Map.get(map, loc))]

  @doc """
  Check if given location is valid.
  """
  @spec valid?(loc, integer) :: boolean
  def valid?({x, y}, _) when x < 0 or y < 0, do: false
  def valid?({x, y}, n) do
    (x * x + 3 * x + 2 * x * y + y + y * y + n)
    |> do_valid(true)
  end

  defp do_valid(0, acc), do: acc
  defp do_valid(n, acc) when (n &&& 1) == 1, do: do_valid(n >>> 1, !acc)
  defp do_valid(n, acc), do: do_valid(n >>> 1, acc)

  @doc """
  Draw the map.
  """
  @spec map({integer, integer}, loc, integer, [loc]) :: :ok
  def map({w, h}, {x, y}, n, path) do
    for j <- 0..h, i <- 0..w do
      case {i, j} do
        {^x, ^y} -> :target
        loc -> if loc in path, do: :path, else: valid?(loc, n)
      end
    end
    |> Stream.map(fn
      true -> "."
      false -> "#"
      :target -> "@"
      :path -> "0"
    end)
    |> Stream.chunk(w + 1)
    |> Enum.map_join("\n", &Enum.join(&1, " "))
    |> IO.puts()
  end
end

defmodule PQueue do
  @moduledoc """
  Priority queue implemented via :gb_trees.
  """

  @type t :: :gb_tree.tree

  @doc """
  Create an empty priority queue.
  """
  @spec new() :: t
  def new do
    :gb_trees.empty()
  end

  @doc """
  Put item with priority in the priority queue. For the items have the same priority,
  the order is preserved.
  """
  @spec put(t, term, term) :: t
  def put(pqueue, item, priority) do
    :gb_trees.insert({priority, :erlang.unique_integer()}, item, pqueue)
  end

  @doc """
  Take out the item with lowest priority.
  """
  @spec out(t) :: {term, t}
  def out(pqueue) do
    {_, item, pqueue} = :gb_trees.take_smallest(pqueue)
    {item, pqueue}
  end

  @doc """
  Peek the head of the queue.
  """
  @spec peek(t) :: {term, term}
  def peek(pqueue) do
    {{priority, _}, item} = :gb_trees.smallest(pqueue)
    {item, priority}
  end
end
