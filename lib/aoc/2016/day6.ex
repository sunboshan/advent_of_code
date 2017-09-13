defmodule AOC2016.Day6 do
  @moduledoc """
  Day 6: Signals and Noise
  """

  def run1 do
    File.read!("priv/2016/6.txt")
    |> ecc()
  end

  def run2 do
    File.read!("priv/2016/6.txt")
    |> ecc2()
  end

  @doc """
  Find the ecc from input.

  iex> AOC2016.Day6.ecc("eedadn\\ndrvtee\\neandsr\\nraavrd\\natevrs\\ntsrnev\\nsdttsa\\nrasrtv\\nnssdts\\nntnada\\nsvetve\\ntesnvt\\nvntsnd\\nvrdear\\ndvrsen\\nenarar")
  "easter"
  """
  def ecc(input) do
    String.split(input)
    |> Stream.map(&String.codepoints/1)
    |> Stream.zip()
    |> Stream.map(fn e ->
      Tuple.to_list(e)
      |> Enum.reduce(%{}, &Map.update(&2, &1, 1, fn i -> i + 1 end))
      |> Enum.max_by(&elem(&1, 1))
    end)
    |> Enum.map_join(&elem(&1, 0))
  end

  @doc """
  Find the ecc from input for least common letter.

  iex> AOC2016.Day6.ecc2("eedadn\\ndrvtee\\neandsr\\nraavrd\\natevrs\\ntsrnev\\nsdttsa\\nrasrtv\\nnssdts\\nntnada\\nsvetve\\ntesnvt\\nvntsnd\\nvrdear\\ndvrsen\\nenarar")
  "advent"
  """
  def ecc2(input) do
    String.split(input)
    |> Stream.map(&String.codepoints/1)
    |> Stream.zip()
    |> Stream.map(fn e ->
      Tuple.to_list(e)
      |> Enum.reduce(%{}, &Map.update(&2, &1, 1, fn i -> i + 1 end))
      |> Enum.min_by(&elem(&1, 1))
    end)
    |> Enum.map_join(&elem(&1, 0))
  end
end
