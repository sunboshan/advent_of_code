defmodule AOC2016.Day7 do
  @moduledoc """
  Day 7: Internet Protocol Version 7
  """

  def run1 do
    File.read!("priv/2016/7.txt")
    |> String.split()
    |> Enum.count(&tls?/1)
  end

  def run2 do
    File.read!("priv/2016/7.txt")
    |> String.split()
    |> Enum.count(&ssl?/1)
  end

  @doc """
  TLS check.

  iex> AOC2016.Day7.tls?("abba[mnop]qrst")
  true
  iex> AOC2016.Day7.tls?("abcd[bddb]xyyx")
  false
  iex> AOC2016.Day7.tls?("aaaa[qwer]tyui")
  false
  iex> AOC2016.Day7.tls?("ioxxoj[asdfgh]zxcvbn")
  true
  """
  @spec tls?(String.t) :: boolean
  def tls?(input) do
    with false <- Regex.scan(~r/\[(\w+)\]/, input)
        |> Enum.any?(fn [_, e] -> abba?(e) end) do
      Regex.split(~r/\[\w+\]/, input)
      |> Enum.any?(&abba?/1)
    else
      _ -> false
    end
  end

  defp abba?(<<a, b, b, a, _::binary>>) when a != b, do: true
  defp abba?(<<_, t::binary>>), do: abba?(t)
  defp abba?(<<>>), do: false

  @doc """
  SSL check.

  iex> AOC2016.Day7.ssl?("aba[bab]xyz")
  true
  iex> AOC2016.Day7.ssl?("xyx[xyx]xyx")
  false
  iex> AOC2016.Day7.ssl?("aaa[kek]eke")
  true
  iex> AOC2016.Day7.ssl?("zazbz[bzb]cdb")
  true
  """
  @spec ssl?(String.t) :: boolean
  def ssl?(input) do
    hypernet = Regex.scan(~r/\[(\w+)\]/, input)
      |> Enum.map(fn [_, e] -> e end)

    Regex.split(~r/\[\w+\]/, input)
    |> Stream.flat_map(&aba/1)
    |> Enum.any?(fn <<a, b, a>> ->
      Enum.any?(hypernet, &String.contains?(&1, <<b, a, b>>))
    end)
  end

  defp aba(string) do
    do_aba(string, [])
  end

  defp do_aba(<<a, b, a, t::binary>>, acc) when a != b do
    do_aba(<<b, a, t::binary>>, [<<a, b, a>> | acc])
  end
  defp do_aba(<<_, t::binary>>, acc), do: do_aba(t, acc)
  defp do_aba(<<>>, acc), do: acc
end
