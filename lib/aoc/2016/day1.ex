defmodule AOC2016.Day1 do
  @moduledoc """
  Day 1: No Time for a Taxicab

  This can be solved using a finite state machine.

  state      L          R
  :N     {-x, :W}   {+x, :E}
  :S     {+x, :E}   {-x, :W}
  :E     {+y, :N}   {-y, :S}
  :W     {-y, :S}   {+y, :N}
  """

  @behaviour :gen_statem

  def run1 do
    File.read!("priv/2016/1.txt")
    |> String.trim()
    |> taxicab()
  end

  def run2 do
    File.read!("priv/2016/1.txt")
    |> String.trim()
    |> first_location()
  end

  ###########
  ### API ###
  ###########

  def start_link do
    :gen_statem.start_link(__MODULE__, [], [])
  end

  @doc """
  Part 1, get the taxicab distance for a given input.

  iex> AOC2016.Day1.taxicab("R2, L3")
  5
  iex> AOC2016.Day1.taxicab("R2, R2, R2")
  2
  iex> AOC2016.Day1.taxicab("R5, L5, R5, R3")
  12
  """
  def taxicab(input) do
    {:ok, pid} = start_link()
    String.split(input, ", ")
    |> Stream.map(&direction/1)
    |> Enum.each(&move(pid, &1))
    {x, y} = get(pid)
    abs(x) + abs(y)
  end

  defp direction(<<direction::binary-1, i::binary>>) do
    {String.to_atom(direction), String.to_integer(i)}
  end

  @doc """
  Part 2, get the distance of the first location that visited twice.

  iex> AOC2016.Day1.first_location("R8, R4, R4, R8")
  4
  """
  def first_location(input) do
    {:ok, pid} = start_link()
    {x, y} = String.split(input, ", ")
      |> Stream.flat_map(&steps/1)
      |> Enum.map(fn direction ->
        move(pid, direction)
        get(pid)
      end)
      |> do_first_location([])
    abs(x) + abs(y)
  end

  defp do_first_location([], _), do: {0, 0}
  defp do_first_location([h | t], acc) do
    if h in acc, do: h, else: do_first_location(t, [h | acc])
  end

  defp steps("L1"), do: [L: 1]
  defp steps("R1"), do: [R: 1]
  defp steps(<<direction::binary-1, i::binary>>) do
    for _ <- 2..String.to_integer(i), into: [{String.to_atom(direction), 1}] do
      {:F, 1}
    end
  end

  defp move(pid, direction) do
    :gen_statem.cast(pid, direction)
  end

  defp get(pid) do
    :gen_statem.call(pid, :get)
  end

  #################
  ### Callbacks ###
  #################

  def callback_mode do
    :handle_event_function
  end

  def init(_) do
    {:ok, :N, {0, 0}}
  end

  def handle_event(:cast, {:L, i}, :N, {x, y}), do: {:next_state, :W, {x - i, y}}
  def handle_event(:cast, {:R, i}, :N, {x, y}), do: {:next_state, :E, {x + i, y}}
  def handle_event(:cast, {:F, i}, :N, {x, y}), do: {:keep_state,     {x, y + i}}

  def handle_event(:cast, {:L, i}, :S, {x, y}), do: {:next_state, :E, {x + i, y}}
  def handle_event(:cast, {:R, i}, :S, {x, y}), do: {:next_state, :W, {x - i, y}}
  def handle_event(:cast, {:F, i}, :S, {x, y}), do: {:keep_state,     {x, y - i}}

  def handle_event(:cast, {:L, i}, :E, {x, y}), do: {:next_state, :N, {x, y + i}}
  def handle_event(:cast, {:R, i}, :E, {x, y}), do: {:next_state, :S, {x, y - i}}
  def handle_event(:cast, {:F, i}, :E, {x, y}), do: {:keep_state,     {x + i, y}}

  def handle_event(:cast, {:L, i}, :W, {x, y}), do: {:next_state, :S, {x, y - i}}
  def handle_event(:cast, {:R, i}, :W, {x, y}), do: {:next_state, :N, {x, y + i}}
  def handle_event(:cast, {:F, i}, :W, {x, y}), do: {:keep_state,     {x - i, y}}


  def handle_event({:call, from}, :get, _, data) do
    {:keep_state_and_data, {:reply, from, data}}
  end
  def handle_event(_, _, _, data) do
    {:keep_state, data}
  end
end
