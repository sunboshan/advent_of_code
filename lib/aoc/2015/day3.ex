defmodule AOC2015.Day3 do
  @moduledoc """
  Day 3: Perfectly Spherical Houses in a Vacuum
  """

  import Bitwise

  def run1 do
    File.read!("priv/2015/3.txt")
    |> String.trim()
    |> deliver()
  end

  def run2 do
    File.read!("priv/2015/3.txt")
    |> String.trim()
    |> deliver2()
  end

  def deliver(input) do
    do_deliver(input, {0, 0}, MapSet.new())
  end

  defp do_deliver(<<>>, {x, y}, acc) do
    MapSet.put(acc, {x, y})
    |> MapSet.size()
  end
  defp do_deliver(<<?^, t::binary>>, {x, y}, acc) do
    do_deliver(t, {x, y + 1}, MapSet.put(acc, {x, y}))
  end
  defp do_deliver(<<?v, t::binary>>, {x, y}, acc) do
    do_deliver(t, {x, y - 1}, MapSet.put(acc, {x, y}))
  end
  defp do_deliver(<<?<, t::binary>>, {x, y}, acc) do
    do_deliver(t, {x - 1, y}, MapSet.put(acc, {x, y}))
  end
  defp do_deliver(<<?>, t::binary>>, {x, y}, acc) do
    do_deliver(t, {x + 1, y}, MapSet.put(acc, {x, y}))
  end

  def deliver2(input) do
    do_deliver2(input, 0, {[{0, 0}], [{0, 0}]})
  end

  defp do_deliver2(<<>>, _, {a, b}) do
    MapSet.new(a ++ b)
    |> MapSet.size()
  end
  defp do_deliver2(<<?^, t::binary>>, n, acc) do
    acc = update_in(acc, [Access.elem(n)], fn [{x, y} | _] = e ->
      [{x, y + 1} | e]
    end)
    do_deliver2(t, n ^^^ 1, acc)
  end
  defp do_deliver2(<<?v, t::binary>>, n, acc) do
    acc = update_in(acc, [Access.elem(n)], fn [{x, y} | _] = e ->
      [{x, y - 1} | e]
    end)
    do_deliver2(t, n ^^^ 1, acc)
  end
  defp do_deliver2(<<?<, t::binary>>, n, acc) do
    acc = update_in(acc, [Access.elem(n)], fn [{x, y} | _] = e ->
      [{x - 1, y} | e]
    end)
    do_deliver2(t, n ^^^ 1, acc)
  end
  defp do_deliver2(<<?>, t::binary>>, n, acc) do
    acc = update_in(acc, [Access.elem(n)], fn [{x, y} | _] = e ->
      [{x + 1, y} | e]
    end)
    do_deliver2(t, n ^^^ 1, acc)
  end
end
