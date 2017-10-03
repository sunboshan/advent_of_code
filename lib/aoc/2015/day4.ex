defmodule AOC2015.Day4 do
  @moduledoc """
  Day 4: The Ideal Stocking Stuffer
  """

  def run1 do
    input = "yzbqklnj"
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&:crypto.hash(:md5, "#{input}#{&1}"))
    |> Enum.find_index(&check/1)
    |> Kernel.+(1)
  end

  def run2 do
    input = "yzbqklnj"
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&:crypto.hash(:md5, "#{input}#{&1}"))
    |> Enum.find_index(&check2/1)
    |> Kernel.+(1)
  end

  def check(<<0::20, _::bits>>), do: true
  def check(_), do: false

  def check2(<<0::24, _::bits>>), do: true
  def check2(_), do: false
end
