defmodule AOC2016.Day12 do
  @moduledoc """
  Day 12: Leonardo's Monorail

  Use a doubly linked list here to preserve the instruction history.
  """

  def run0 do
    """
    cpy 41 a
    inc a
    inc a
    dec a
    jnz a 2
    dec a
    """
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> process()
  end

  def run1 do
    File.read!("priv/2016/12.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> process()
  end

  def run2 do
    File.read!("priv/2016/12.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> process({0, 0, 1, 0})
  end

  defp parse("cpy" <> _ = str) do
    [_, x, <<y>>] = Regex.run(~r/cpy (\w+) (.)/, str)
    x = case x do
      <<x>> when x in ?a..?d -> {:reg, x - ?a}
      x -> {:val, String.to_integer(x)}
    end
    {:cpy, x, y - ?a}
  end
  defp parse("jnz" <> _ = str) do
    [_, x, n] = Regex.run(~r/jnz (.) (.*)/, str)
    x = case x do
      <<x>> when x in ?a..?d -> {:reg, x - ?a}
      x -> {:val, String.to_integer(x)}
    end
    {:jnz, x, String.to_integer(n)}
  end
  defp parse(<<"inc ", x>>), do: {:inc, x - ?a}
  defp parse(<<"dec ", x>>), do: {:dec, x - ?a}

  @doc """
  Process on the instruction set.
  """
  def process(list, initial \\ {0, 0, 0, 0}) do
    do_process({list, []}, initial)
  end

  defp do_process({[], _}, acc), do: acc
  defp do_process({[{:cpy, {:val, v}, y} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, y, v))
  end
  defp do_process({[{:cpy, {:reg, x}, y} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, y, elem(acc, x)))
  end
  defp do_process({[{:inc, x} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) + 1))
  end
  defp do_process({[{:dec, x} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) - 1))
  end
  defp do_process({[{:jnz, {:reg, x}, _} = h | t], old}, acc) when elem(acc, x) == 0 do
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:jnz, {:val, 0}, _} = h | t], old}, acc) do
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:jnz, {:reg, _}, n} | _] = new, old}, acc) when n < 0 do
    Stream.iterate({new, old}, fn {new, [h | t]} -> {[h | new], t} end)
    |> Enum.at(abs(n))
    |> do_process(acc)
  end
  defp do_process({[{:jnz, _, n} | _] = new, old}, acc) do
    Stream.iterate({new, old}, fn {[h | t], old} -> {t, [h | old]} end)
    |> Enum.at(n)
    |> do_process(acc)
  end
end
