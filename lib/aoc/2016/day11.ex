defmodule AOC2016.Day11 do
  @moduledoc """
  Day 11: Radioisotope Thermoelectric Generators

  Use breadth-first search(BFS).

  Since the there's only 4 floors, we can use 2 bits to represent
  elevator/generator/microchip's floor number.

      00 00 00 00 00 ...
      e  g1 m1 g2 m2 ...

  The solution is in `priv/2016/11_solution.txt`
  """

  import Bitwise

  @type move :: bitstring

  @doc """
  The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
  The second floor contains a hydrogen generator.
  The third floor contains a lithium generator.
  The fourth floor contains nothing relevant.

  Average running time: 4ms
  """
  def run0 do
    root = <<0b00_0100_1000::10>>
    stop = <<0b11_1111_1111::10>>
    run(root, stop)
  end

  @doc """
  The first floor contains a thulium generator, a thulium-compatible microchip, a plutonium generator, and a strontium generator.
  The second floor contains a plutonium-compatible microchip and a strontium-compatible microchip.
  The third floor contains a promethium generator, a promethium-compatible microchip, a ruthenium generator, and a ruthenium-compatible microchip.
  The fourth floor contains nothing relevant.

  Average running time: 50ms
  """
  def run1 do
    root = <<0b00_0000_0001_0001_1010_1010::22>>
    stop = <<0b11_1111_1111_1111_1111_1111::22>>
    run(root, stop)
  end

  @doc """
  Same input as above, plus two generator/microchip pairs in the first floor.

  Average running time: 300ms
  """
  def run2 do
    root = <<0b00_0000_0001_0001_1010_1010_0000_0000::30>>
    stop = <<0b11_1111_1111_1111_1111_1111_1111_1111::30>>
    run(root, stop)
  end

  def run(root, stop) do
    traverse(root, stop)
    |> :digraph.get_path(root, stop)
    |> Stream.with_index()
    |> Enum.each(fn {move, i} ->
      IO.puts "Move #{i}"
      display(move)
    end)
  end

  @doc """
  Traverse from root node to stop node.

  The BFS algorithm goes like this:
    - remove the current node from queue
    - for every possible move, check if it's already visited:
      - if so, do nothing and move on
      - if not
        - add the move to the queue
        - add the normalized move to the vistied list
    - stop at the target node
  """
  @spec traverse(move, move) :: :diagraph.graph
  def traverse(root, stop) do
    queue = :queue.from_list([root])
    visited = []
    tree = :digraph.new([:acyclic])
    do_traverse({root, nil}, stop, queue, visited, tree)
  end

  defp do_traverse({stop, parent}, stop, queue, visited, tree) do
    IO.puts "visted nodes: #{length(visited)}"
    IO.puts "remaining nodes in queue: #{:queue.len(queue)}"
    vertex = :digraph.add_vertex(tree, stop)
    :digraph.add_edge(tree, parent, vertex)
    tree
  end
  defp do_traverse({node, parent}, stop, queue, visited, tree) do
    queue = :queue.drop(queue)
    vertex = :digraph.add_vertex(tree, node)
    :digraph.add_edge(tree, parent, vertex)
    {queue, visited} = Enum.reduce(moves(node), {queue, visited}, fn move, {queue, visited} ->
      if normalize(move) in visited do
        {queue, visited}
      else
        {:queue.in({move, vertex}, queue), [normalize(move) | visited]}
      end
    end)
    do_traverse(:queue.get(queue), stop, queue, visited, tree)
  end

  @doc """
  Normalize the given move. The following two moves should be considered same.

  Example:

            M  M
      E GM G  G     00 0000 0001 0001

         M  M
      E G  G  GM    00 0001 0001 0000

      iex> AOC2016.Day11.normalize(<<0b00_0000_0001_0001::14>>)
      <<0, 17::size(6)>>
      iex> AOC2016.Day11.normalize(<<0b00_0001_0001_0000::14>>)
      <<0, 17::size(6)>>
  """
  @spec normalize(move) :: move
  def normalize(<<e::2, t::bits>>) do
    (for <<gm::4 <- t>>, do: gm)
    |> Enum.sort()
    |> do_normalize(<<e::2>>)
  end

  defp do_normalize([], acc), do: acc
  defp do_normalize([h | t], acc) do
    do_normalize(t, <<acc::bits, h::4>>)
  end

  @doc """
  Check if the given move is a valid move. It's invalid if on any row, there is a
  microchip with a generator that not its own.

  Check the generator/microchip in pair:
    - if they are in the same row, mark the row as :g
    - if they are in different rows:
      - mark the generator row as :g
      - mark the microchip row as :m
    - as long as :m meets :g or :g meets :m, mark the row as false
    - as long as there is one row marked as false, the move is invalid
    - otherwise, the move is valid

  Example:

        G  GM G
      E  M     M      00 0100 0101 0100  valid

        G   M G
      E  M G   M      00 0100 0001 0100  invalid

      iex> AOC2016.Day11.valid?(<<0b00_0100_0101_0100::14>>)
      true
      iex> AOC2016.Day11.valid?(<<0b00_0100_0001_0100::14>>)
      false
  """
  @spec valid?(move) :: boolean
  def valid?(<<_::2, t::bits>>) do
    do_valid(t, {nil, nil, nil, nil})
  end

  defp do_valid(<<gm::2, gm::2, t::bits>>, acc) do
    acc = update_in(acc, [Access.elem(gm)], &mark_g/1)
    do_valid(t, acc)
  end
  defp do_valid(<<g::2, m::2, t::bits>>, acc) do
    acc = update_in(acc, [Access.elem(g)], &mark_g/1)
      |> update_in([Access.elem(m)], &mark_m/1)
    do_valid(t, acc)
  end
  defp do_valid(<<>>, {false, _, _, _}), do: false
  defp do_valid(<<>>, {_, false, _, _}), do: false
  defp do_valid(<<>>, {_, _, false, _}), do: false
  defp do_valid(<<>>, {_, _, _, false}), do: false
  defp do_valid(<<>>, _),                do: true

  defp mark_g(nil), do: :g
  defp mark_g(:m),  do: false
  defp mark_g(n),   do: n

  defp mark_m(nil), do: :m
  defp mark_m(:g),  do: false
  defp mark_m(n),   do: n

  @doc """
  Get all possible valid moves from a given move.

    - always move up two items first
    - if there's no valid two-items-up move, then move one item up
    - move down one item
    - filter only the valid moves
  """
  @spec moves(move) :: [move]
  def moves(move) do
    ~w(gm gg mm)a
    |> Stream.flat_map(&move_up(move, &1))
    |> Enum.filter(&valid?/1)
    |> add_move_up(move)
    |> Stream.concat(move_down(move))
    |> Enum.filter(&valid?/1)
  end

  defp add_move_up([], move), do: move_up(move, :x)
  defp add_move_up(moves, _), do: moves

  @doc """
  Move up two items or one item.

    - generator/microchip pair
    - generator/generator
    - microchip/microchip

  For generator/microchip pair, we only need to move the first pair, since they
  all considered same.

  For generator/generator or microchip/microchip, we need to move all the
  combinations of those, since not all of them considered same.
  """
  @spec move_up(move, :gm | :gg | :mm) :: [move]
  def move_up(<<0b11::2, _::bits>>, _), do: []
  def move_up(<<e::2, t::bits>>, :gm) do
    do_move_up_gm(t, e, <<(e + 1)::2>>)
  end
  def move_up(<<e::2, t::bits>>, :gg) do
    (for <<^e::2, _::2 <- t>>, do: e)
    |> length()
    |> combination2()
    |> Enum.map(&<<(e + 1)::2, do_move_up_gg(t, e, &1)::bits>>)
  end
  def move_up(<<e::2, t::bits>>, :mm) do
    (for <<_::2, ^e::2 <- t>>, do: e)
    |> length()
    |> combination2()
    |> Enum.map(&<<(e + 1)::2, do_move_up_mm(t, e, &1)::bits>>)
  end
  def move_up(<<e::2, t::bits>>, :x) do
    (for <<^e::2 <- t>>, do: e)
    |> length()
    |> combination1()
    |> Enum.map(&<<(e + 1)::2, do_move_up_x(t, e, &1)::bits>>)
  end

  defp do_move_up_gm(<<>>, _, _), do: []
  defp do_move_up_gm(<<e::2, e::2, t::bits>>, e, acc) do
    [<<acc::bits, (e + 1)::2, (e + 1)::2, t::bits>>]
  end
  defp do_move_up_gm(<<gm::4, t::bits>>, e, acc) do
    do_move_up_gm(t, e, <<acc::bits, gm::4>>)
  end

  defp do_move_up_gg(<<>>, _, <<>>), do: <<>>
  defp do_move_up_gg(<<e::2, m::2, t1::bits>>, e, <<c::1, t2::bits>>) do
    <<(e + c)::2, m::2, do_move_up_gg(t1, e, t2)::bits>>
  end
  defp do_move_up_gg(<<gm::4, t::bits>>, e, comb) do
    <<gm::4, do_move_up_gg(t, e, comb)::bits>>
  end

  defp do_move_up_mm(<<>>, _, <<>>), do: <<>>
  defp do_move_up_mm(<<g::2, e::2, t1::bits>>, e, <<c::1, t2::bits>>) do
    <<g::2, (e + c)::2, do_move_up_mm(t1, e, t2)::bits>>
  end
  defp do_move_up_mm(<<gm::4, t::bits>>, e, comb) do
    <<gm::4, do_move_up_mm(t, e, comb)::bits>>
  end

  defp do_move_up_x(<<>>, _, <<>>), do: <<>>
  defp do_move_up_x(<<e::2, t1::bits>>, e, <<c::1, t2::bits>>) do
    <<(e + c)::2, do_move_up_x(t1, e, t2)::bits>>
  end
  defp do_move_up_x(<<n::2, t::bits>>, e, comb) do
    <<n::2, do_move_up_x(t, e, comb)::bits>>
  end

  @doc """
  Only move down one item.
  """
  @spec move_down(move) :: [move]
  def move_down(<<0b00::2, _::bits>>), do: []
  def move_down(<<e::2, t::bits>>) do
    (for <<^e::2 <- t>>, do: e)
    |> length()
    |> combination1()
    |> Enum.map(&<<(e - 1)::2, do_move_down(t, e, &1)::bits>>)
  end

  defp do_move_down(<<>>, _, <<>>), do: <<>>
  defp do_move_down(<<e::2, t1::bits>>, e, <<c::1, t2::bits>>) do
    <<(e - c)::2, do_move_down(t1, e, t2)::bits>>
  end
  defp do_move_down(<<n::2, t::bits>>, e, comb) do
    <<n::2, do_move_down(t, e, comb)::bits>>
  end

  @doc """
  Returns all combination of one for a given size.

  Example:

      iex> AOC2016.Day11.combination1(2)
      [<<0b01::2>>, <<0b10::2>>]
      iex> AOC2016.Day11.combination1(3)
      [<<0b001::3>>, <<0b010::3>>, <<0b100::3>>]
      iex> AOC2016.Day11.combination1(4)
      [<<0b0001::4>>, <<0b0010::4>>, <<0b0100::4>>, <<0b1000::4>>]
  """
  @spec combination1(integer) :: [bitstring]
  def combination1(n) do
    Stream.iterate(1, &(&1 <<< 1))
    |> Enum.take(n)
    |> Enum.map(&<<&1::size(n)>>)
  end

  @doc """
  Returns all combination of two for a given size.

  Example:

      iex> AOC2016.Day11.combination2(2)
      [<<0b11::2>>]
      iex> AOC2016.Day11.combination2(3)
      [<<0b110::3>>, <<0b011::3>>, <<0b101::3>>]
      iex> AOC2016.Day11.combination2(4)
      [<<0b1100::4>>, <<0b0110::4>>, <<0b1010::4>>,
       <<0b0011::4>>, <<0b0101::4>>, <<0b1001::4>>]
  """
  @spec combination2(integer) :: [bitstring]
  def combination2(n) do
    Stream.iterate(1, &(&1 <<< 1))
    |> Enum.take(n)
    |> do_combination2([])
    |> Enum.map(&<<&1::size(n)>>)
  end

  defp do_combination2([], acc), do: acc
  defp do_combination2([h | t], acc) do
    list = (for e <- t, do: h + e)
    do_combination2(t, list ++ acc)
  end

  @doc """
  Display the move visually.

         00 00 00 01 10
      -----------------
      F4 .  .  .  .  .
      F3 .  .  .  .  M2
      F2 .  .  .  G2 .
      F1 E  G1 M1 .  .
      -----------------
  """
  @spec display(move) :: :ok
  def display(<<e::2, t::bits>>) do
    n = div(bit_size(t), 2) + 2
    seperator = String.duplicate("-", n * 3 - 1)
    IO.puts(seperator)
    matrix = Tuple.duplicate(nil, n)
      |> Tuple.duplicate(4)
    matrix = Enum.reduce(1..4, matrix, &put(&2, {&1 - 1, 0}, "F#{&1}"))
      |> put({e, 1}, "E ")
    (for <<gm::bits-4 <- t>>, do: gm)
    |> Stream.with_index(1)
    |> Enum.reduce(matrix, fn {<<g::2, m::2>>, i}, acc ->
      put(acc, {g, i * 2}, "G#{i}")
      |> put({m, i * 2 + 1}, "M#{i}")
    end)
    |> Tuple.to_list()
    |> Enum.reverse()
    |> Enum.map_join("\n", fn
      row when elem(row, 1) == nil ->
        Tuple.to_list(row)
        |> Enum.map_join(" ", &do_display/1)
      row ->
        row = Tuple.to_list(row)
        |> Enum.map_join(" ", &do_display/1)
        IO.ANSI.format([:light_blue_background, :light_white, row])
    end)
    |> IO.puts()
    IO.puts(seperator)
  end

  defp do_display(nil), do: ". "
  defp do_display(msg), do: msg

  defp put(matrix, {x, y}, value) do
    put_in(matrix, [Access.elem(x), Access.elem(y)], value)
  end
end
