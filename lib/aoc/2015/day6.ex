defmodule AOC2015.Day6 do
  @moduledoc """
  Day 6: Probably a Fire Hazard
  """

  import Bitwise

  def run1 do
    File.read!("priv/2015/6.txt")
    |> parse()
    |> Enum.reduce(new(), &update(&2, &1))
    |> lit()
  end

  def run2 do
    File.read!("priv/2015/6.txt")
    |> parse()
    |> Enum.reduce(new(), &update2(&2, &1))
    |> lit()
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
  end

  defp do_parse("turn off" <> _ = str) do
    [a, b, x, y] = Regex.scan(~r/\d+/, str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    {:off, {a, b}, {x, y}}
  end
  defp do_parse("turn on" <> _ = str) do
    [a, b, x, y] = Regex.scan(~r/\d+/, str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    {:on, {a, b}, {x, y}}
  end
  defp do_parse("toggle" <> _ = str) do
    [a, b, x, y] = Regex.scan(~r/\d+/, str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    {:toggle, {a, b}, {x, y}}
  end

  def new do
    Tuple.duplicate(0, 1_000)
    |> Tuple.duplicate(1_000)
  end

  def lit(matrix) do
    Enum.reduce(0..999, 0, fn j, acc ->
      Enum.reduce(0..999, acc, fn i, acc ->
        acc + get_in(matrix, [Access.elem(j), Access.elem(i)])
      end)
    end)
  end

  def update(matrix, {:on, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        put_in(acc, [Access.elem(j), Access.elem(i)], 1)
      end)
    end)
  end
  def update(matrix, {:off, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        put_in(acc, [Access.elem(j), Access.elem(i)], 0)
      end)
    end)
  end
  def update(matrix, {:toggle, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        update_in(acc, [Access.elem(j), Access.elem(i)], &(&1 ^^^ 1))
      end)
    end)
  end

  def update2(matrix, {:on, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        update_in(acc, [Access.elem(j), Access.elem(i)], &(&1 + 1))
      end)
    end)
  end
  def update2(matrix, {:off, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        update_in(acc, [Access.elem(j), Access.elem(i)], &max(&1 - 1, 0))
      end)
    end)
  end
  def update2(matrix, {:toggle, {a, b}, {x, y}}) do
    Enum.reduce(b..y, matrix, fn j, acc ->
      Enum.reduce(a..x, acc, fn i, acc ->
        update_in(acc, [Access.elem(j), Access.elem(i)], &(&1 + 2))
      end)
    end)
  end
end
