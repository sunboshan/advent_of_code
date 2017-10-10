defmodule AOC2015.Day14 do
  @moduledoc """
  Day 14: Reindeer Olympics
  """

  def run0 do
    """
    Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
    Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
    """
    |> parse()
    |> race(1000)
  end

  def run1 do
    File.read!("priv/2015/14.txt")
    |> parse()
    |> race(2503)
  end

  def run2 do
    File.read!("priv/2015/14.txt")
    |> parse()
    |> race2(2503)
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&do_parse/1)
    |> Map.new()
  end

  defp do_parse(str) do
    [a, x, y, z] = Regex.run(~r/^(\w+) .* (\d+) .* (\d+) .* (\d+)/, str, capture: :all_but_first)
    {a, {String.to_integer(x), String.to_integer(y), String.to_integer(z)}}
  end

  def race(map, time) do
    (for {_, v} <- map, do: fly(v, time))
    |> Enum.max()
  end

  def fly({speed, duration, rest}, total) do
    full = speed * duration
    time = duration + rest
    distance = case rem(total, time) do
      n when n >= duration -> full
      n -> speed * n
    end
    distance + div(total, time) * full
  end

  def race2(map, time) do
    scores = for {k, v} <- map, into: %{}, do: {k, {v, 0}}
    Enum.reduce(1..time, scores, &lead(&2, &1))
    |> Enum.max_by(fn {_, {_, v}} -> v end)
    |> get_in([Access.elem(1), Access.elem(1)])
  end

  def lead(scores, time) do
    score = Enum.map(scores, fn {k, {meta, _}} ->
      {k, fly(meta, time)}
    end)
    max = Enum.max_by(score, &elem(&1, 1))
      |> elem(1)
    Enum.reduce(score, scores, fn
      {k, ^max}, acc ->
        Map.update!(acc, k, fn {meta, s} ->
          {meta, s + 1}
        end)
      _, acc -> acc
    end)
  end
end
