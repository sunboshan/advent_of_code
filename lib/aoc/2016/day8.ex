defmodule AOC2016.Day8 do
  @moduledoc """
  Day 8: Two-Factor Authentication
  """

  @width  50
  @height 6

  def run1 do
    File.read!("priv/2016/8.txt")
    |> parse()
    |> lit()
  end

  def run2 do
    File.read!("priv/2016/8.txt")
    |> parse()
    |> render()
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.reduce(new(), fn e, acc ->
      do_parse(e, acc)
    end)
  end

  defp do_parse("rect" <> e, matrix) do
    [_, w, h] = Regex.run(~r/(\d+)x(\d+)/, e)
    rect(matrix, {String.to_integer(w), String.to_integer(h)})
  end
  defp do_parse("rotate column" <> e, matrix) do
    [_, j, n] = Regex.run(~r/x=(\d+) by (\d+)/, e)
    rotate_col(matrix, {String.to_integer(j), String.to_integer(n)})
  end
  defp do_parse("rotate row" <> e, matrix) do
    [_, i, n] = Regex.run(~r/y=(\d+) by (\d+)/, e)
    rotate_row(matrix, {String.to_integer(i), String.to_integer(n)})
  end

  def new do
    Tuple.duplicate(0, @width)
    |> Tuple.duplicate(@height)
  end

  def rect(matrix, {w, h}) do
    (for i <- 1..h, j <- 1..w, do: {i - 1, j - 1})
    |> Enum.reduce(matrix, fn {i, j}, acc ->
      put_in(acc, [Access.elem(i), Access.elem(j)], 1)
    end)
  end

  def rotate_col(matrix, {j, n}) do
    Enum.reduce(0..(@height - 1), matrix, fn i, acc ->
      k = case i - rem(n, @height) do
        k when k < 0 -> k + @height
        k -> k
      end
      v = get_in(matrix, [Access.elem(k), Access.elem(j)])
      put_in(acc, [Access.elem(i), Access.elem(j)], v)
    end)
  end

  def rotate_row(matrix, {i, n}) do
    Enum.reduce(0..(@width - 1), matrix, fn j, acc ->
      k = case j - rem(n, @width) do
        k when k < 0 -> k + @width
        k -> k
      end
      v = get_in(matrix, [Access.elem(i), Access.elem(k)])
      put_in(acc, [Access.elem(i), Access.elem(j)], v)
    end)
  end

  def lit(matrix) do
    Tuple.to_list(matrix)
    |> Enum.reduce(0, &Enum.sum(Tuple.to_list(&1)) + &2)
  end

  def render(matrix) do
    Tuple.to_list(matrix)
    |> Enum.map_join("\n", fn row ->
      Tuple.to_list(row)
      |> Enum.map_join(" ", &do_render/1)
    end)
    |> IO.puts()
  end

  defp do_render(0), do: "."
  defp do_render(1), do: "#"
end
