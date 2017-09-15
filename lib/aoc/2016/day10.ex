defmodule AOC2016.Day10 do
  @moduledoc """
  Day 10: Balance Bots
  """

  def run1 do
    {state, instruction} = File.read!("priv/2016/10.txt")
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, %{}}, &parse/2)

    {_, res} = run(state, instruction, [])
    for {k, [17, 61]} <- res, do: k
  end

  def run2 do
    {state, instruction} = File.read!("priv/2016/10.txt")
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, %{}}, &parse/2)

    {state, _} = run(state, instruction, [])
    (for {{:output, n}, v} <- state, n in ~w(0 1 2), do: v)
    |> List.flatten()
    |> Enum.reduce(&Kernel.*/2)
  end

  @doc """
  Run the bots with instruction.
  """
  def run(state, instruction, acc) do
    with {bot, [l, h]} = item <- Enum.find(state, fn {k, v} -> !is_tuple(k) && length(v) == 2 end) do
      {bot_l, bot_h} = instruction[bot]
      Map.put(state, bot, [])
      |> Map.update(bot_l, [l], &Enum.sort([l | &1]))
      |> Map.update(bot_h, [h], &Enum.sort([h | &1]))
      |> run(instruction, [item | acc])
    else
      nil -> {state, acc}
    end
  end

  defp parse("value" <> _ = input, {state, instruction}) do
    [[value], [bot]] = Regex.scan(~r/\d+/, input)
    value = String.to_integer(value)
    state = Map.update(state, bot, [value], &Enum.sort([value | &1]))
    {state, instruction}
  end
  defp parse("bot" <> _ = input, {state, instruction}) do
    [[bot], [low], [high]] = Regex.scan(~r/\w+ \d+/, input)
    instruction = Map.put(instruction, target(bot), {target(low), target(high)})
    {state, instruction}
  end

  defp target("output " <> n), do: {:output, n}
  defp target("bot "    <> n), do: n
end
