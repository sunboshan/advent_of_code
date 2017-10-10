defmodule AOC2015.Day7 do
  @moduledoc """
  Day 7: Some Assembly Required

  Use an Agent here to save the cache of the calculated value.
  """

  use Agent

  import Bitwise

  def run1 do
    {:ok, pid} = start_link()
    File.read!("priv/2015/7.txt")
    |> parse()
    |> value(pid, "a")
  end

  def run2 do
    {:ok, pid} = start_link(%{"b" => 46065})
    File.read!("priv/2015/7.txt")
    |> parse()
    |> value(pid, "a")
  end

  def start_link(init \\ %{}) do
    Agent.start_link(fn -> init end)
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
    |> Map.new()
  end

  defp do_parse(input) do
    cond do
      Regex.match?(~r/^[a-z]+ ->/, input) ->
        [a, b] = Regex.run(~r/(\w+) -> (\w+)/, input, capture: :all_but_first)
        {b, {:reg, a}}
      Regex.match?(~r/^\d+ ->/, input) ->
        [a, b] = Regex.run(~r/(\d+) -> (\w+)/, input, capture: :all_but_first)
        {b, {:val, String.to_integer(a)}}
      Regex.match?(~r/RSHIFT/, input) ->
        [a, b, c] = Regex.run(~r/(\w+) RSHIFT (\d+) -> (\w+)/, input, capture: :all_but_first)
        {c, {:rshift, a, String.to_integer(b)}}
      Regex.match?(~r/LSHIFT/, input) ->
        [a, b, c] = Regex.run(~r/(\w+) LSHIFT (\d+) -> (\w+)/, input, capture: :all_but_first)
        {c, {:lshift, a, String.to_integer(b)}}
      Regex.match?(~r/1 AND/, input) ->
        [a, b] = Regex.run(~r/1 AND (\w+) -> (\w+)/, input, capture: :all_but_first)
        {b, {:and, a, 1}}
      Regex.match?(~r/AND/, input) ->
        [a, b, c] = Regex.run(~r/(\w+) AND (\w+) -> (\w+)/, input, capture: :all_but_first)
        {c, {:and, a, b}}
      Regex.match?(~r/OR/, input) ->
        [a, b, c] = Regex.run(~r/(\w+) OR (\w+) -> (\w+)/, input, capture: :all_but_first)
        {c, {:or, a, b}}
      Regex.match?(~r/NOT/, input) ->
        [a, b] = Regex.run(~r/NOT (\w+) -> (\w+)/, input, capture: :all_but_first)
        {b, {:not, a}}
    end
  end

  def value(map, pid, key) do
    case Agent.get(pid, &Map.get(&1, key)) do
      nil ->
        v = case Map.get(map, key) do
          {:val, n}       -> n
          {:reg, x}       -> value(map, pid, x)
          {:rshift, a, b} -> value(map, pid, a) >>> b
          {:lshift, a, b} -> value(map, pid, a) <<< b
          {:and, a, 1}    -> value(map, pid, a) &&& 1
          {:and, a, b}    -> value(map, pid, a) &&& value(map, pid, b)
          {:or, a, b}     -> value(map, pid, a) ||| value(map, pid, b)
          {:not, a}       -> ~~~value(map, pid, a)
        end
        Agent.update(pid, &Map.put(&1, key, v))
        v
      v ->
        v
    end
  end
end
