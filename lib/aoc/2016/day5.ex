defmodule AOC2016.Day5 do
  @moduledoc """
  Day 5: How About a Nice Game of Chess?
  """

  def run1 do
    password("reyedfim")
  end

  def run2 do
    password2("reyedfim")
  end

  @doc """
  Find the password according to the hash value.

  iex> AOC2016.Day5.password("abc")
  "18f47a30"
  """
  @spec password(String.t) :: String.t
  def password(input) do
    Stream.unfold(0, fn e ->
      {:crypto.hash(:md5, input <> Integer.to_string(e)), e + 1}
    end)
    |> Stream.filter(&filter/1)
    |> Stream.take(8)
    |> Stream.map(fn <<_::16, password::binary-1, _::binary>> ->
      <<_, p::binary>> = Base.encode16(password, case: :lower)
      IO.puts "Found password #{p}"
      p
    end)
    |> Enum.join()
  end

  defp filter(<<0::20, _::bits>>), do: true
  defp filter(_), do: false

  @doc """
  Find the password according to the hash value and position.

  iex> AOC2016.Day5.password2("abc")
  "05ace8e3"
  """
  @spec password2(String.t) :: String.t
  def password2(input) do
    Stream.unfold(0, fn e ->
      {:crypto.hash(:md5, input <> Integer.to_string(e)), e + 1}
    end)
    |> Stream.filter(&filter2/1)
    |> Stream.map(fn <<_::16, password::binary-2, _::binary>> ->
      <<_, n::binary-1, p::binary-1, _>> = Base.encode16(password, case: :lower)
      {String.to_integer(n), p}
    end)
    |> Enum.flat_map_reduce(%{}, fn {n, p}, acc ->
      acc = Map.put_new(acc, n, p)
      m = map_size(acc)
      IO.puts "Found password #{p} in position #{n}. #{8 - m} more to go."
      if m == 8, do: {:halt, acc}, else: {[], acc}
    end)
    |> elem(1)
    |> Enum.map_join(&elem(&1, 1))
  end

  defp filter2(<<0::21, _::bits>>), do: true
  defp filter2(_), do: false
end
