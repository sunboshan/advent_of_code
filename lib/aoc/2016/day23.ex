defmodule AOC2016.Day23 do
  @moduledoc """
  Day 23: Safe Cracking

  - part 1 is straightforward, use two linked list as doubly linked list
  - part 2 is unable to calculate in normal time, has to do some analysis on the
    input. Turns out it's doing `n! + 75 * 85`, no wonder 12! = 479_001_600
    takes forever to run!
  """

  def run1 do
    File.read!("priv/2016/23.txt")
    |> parse()
    |> process({7, 0, 0, 0})
    |> elem(0)
  end

  def run2 do
    Enum.reduce(1..12, &(&1 * &2)) + 75 * 85
  end

  @doc """
  Parse the input.
  """
  @spec parse(String.t) :: list
  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
  end

  defp do_parse(<<ins::binary-3, t::binary>>) when ins in ~w(cpy jnz) do
    [x, y] = Regex.run(~r/^ (.*) (.*)$/, t, capture: :all_but_first)
      |> Enum.map(&tag/1)
    {String.to_atom(ins), x, y}
  end
  defp do_parse(<<"inc ", x>>), do: {:inc, x - ?a}
  defp do_parse(<<"dec ", x>>), do: {:dec, x - ?a}
  defp do_parse(<<"tgl ", x>>), do: {:tgl, x - ?a}

  defp tag(<<x>>) when x in ?a..?d, do: {:reg, x - ?a}
  defp tag(x),                      do: {:val, String.to_integer(x)}

  @doc """
  Process on the instruction set.
  """
  def process(list, initial \\ {0, 0, 0, 0}) do
    do_process({list, []}, initial)
  end

  defp do_process({[], _}, acc), do: acc
  defp do_process({[{:cpy, val, {:reg, x}} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, x, value(val, acc)))
  end
  defp do_process({[{:inc, x} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) + 1))
  end
  defp do_process({[{:dec, x} = h | t], old}, acc) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) - 1))
  end
  defp do_process({[{:tgl, x} | _] = new, old}, acc) when elem(acc, x) >= 0 do
    n = elem(acc, x)
    [h | t] = List.update_at(new, n, &toggle/1)
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:tgl, x} = h | t], old}, acc) do
    n = abs(elem(acc, x)) - 1
    old = List.update_at(old, n, &toggle/1)
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:jnz, {:val, 0}, _} = h | t], old}, acc) do
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:jnz, {:reg, x}, _} = h | t], old}, acc) when elem(acc, x) == 0 do
    do_process({t, [h | old]}, acc)
  end
  defp do_process({[{:jnz, _, val} | _] = new, old}, acc) do
    case value(val, acc) do
      v when v > 0 ->
        Stream.iterate({new, old}, fn
          {[h | t], old} -> {t, [h | old]}
          {[], old} -> {[], old}
        end)
        |> Enum.at(v)
      v ->
        Stream.iterate({new, old}, fn
          {new, [h | t]} -> {[h | new], t}
          {new, []} -> {new, []}
        end)
        |> Enum.at(abs(v))
    end
    |> do_process(acc)
  end

  defp value({:val, n}, _), do: n
  defp value({:reg, x}, r), do: elem(r, x)

  defp toggle({:inc, x}),    do: {:dec, x}
  defp toggle({_res, x}),    do: {:inc, x}
  defp toggle({:jnz, x, y}), do: {:cpy, x, y}
  defp toggle({_res, x, y}), do: {:jnz, x, y}
end
