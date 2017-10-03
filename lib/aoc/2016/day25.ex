defmodule AOC2016.Day25 do
  @moduledoc """
  Day 25: Clock Signal
  """

  import Bitwise

  def run1 do
    ops = File.read!("priv/2016/25.txt")
      |> parse()
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&process(ops, {&1, 0, 0, 0}))
    |> Enum.find(&(&1))
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
  defp do_parse(<<"out ", x>>), do: {:out, x - ?a}

  defp tag(<<x>>) when x in ?a..?d, do: {:reg, x - ?a}
  defp tag(x),                      do: {:val, String.to_integer(x)}

  @doc """
  Process on the instruction set. Returns true if correct sequence was generated
  200 times.
  """
  @spec process(list, tuple) :: boolean
  def process(list, initial \\ {0, 0, 0, 0}) do
    IO.puts "Processing #{elem(initial, 0)}"
    do_process({list, []}, initial, 0, 200)
  end

  defp do_process(_, _, _, 0), do: true
  defp do_process({[{:cpy, val, {:reg, x}} = h | t], old}, acc, flag, n) do
    do_process({t, [h | old]}, put_elem(acc, x, value(val, acc)), flag, n)
  end
  defp do_process({[{:inc, x} = h | t], old}, acc, flag, n) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) + 1), flag, n)
  end
  defp do_process({[{:dec, x} = h | t], old}, acc, flag, n) do
    do_process({t, [h | old]}, put_elem(acc, x, elem(acc, x) - 1), flag, n)
  end
  defp do_process({[{:jnz, {:val, 0}, _} = h | t], old}, acc, flag, n) do
    do_process({t, [h | old]}, acc, flag, n)
  end
  defp do_process({[{:jnz, {:reg, x}, _} = h | t], old}, acc, flag, n) when elem(acc, x) == 0 do
    do_process({t, [h | old]}, acc, flag, n)
  end
  defp do_process({[{:jnz, _, val} | _] = new, old}, acc, flag, n) do
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
    |> do_process(acc, flag, n)
  end
  defp do_process({[{:out, x} = h | t], old}, acc, flag, n) when elem(acc, x) == flag do
    do_process({t, [h | old]}, acc, flag ^^^ 1, n - 1)
  end
  defp do_process({[{:out, _} | _], _}, _, _, _), do: false

  defp value({:val, n}, _), do: n
  defp value({:reg, x}, r), do: elem(r, x)
end
