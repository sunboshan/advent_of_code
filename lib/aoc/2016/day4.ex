defmodule AOC2016.Day4 do
  @moduledoc """
  Day 4: Security Through Obscurity
  """

  def run1 do
    File.read!("priv/2016/4.txt")
    |> String.split("\n", trim: true)
    |> Stream.map(&check/1)
    |> Enum.sum()
  end

  def run2 do
    File.read!("priv/2016/4.txt")
    |> String.split("\n", trim: true)
    |> Stream.map(&decrypt/1)
    |> Enum.find(fn {_, msg} ->
      String.contains?(msg, ~w(north pole object))
    end)
  end

  @doc """
  Check the input.

  iex> AOC2016.Day4.check("aaaaa-bbb-z-y-x-123[abxyz]")
  123
  iex> AOC2016.Day4.check("a-b-c-d-e-f-g-h-987[abcde]")
  987
  iex> AOC2016.Day4.check("not-a-real-room-404[oarel]")
  404
  iex> AOC2016.Day4.check("totally-real-room-200[decoy]")
  0
  """
  @spec check(String.t) :: integer
  def check(input) do
    do_check(input, %{})
  end

  defp do_check(<<?-, id::binary-3, ?[, checksum::binary-5, ?]>>, acc) do
    check = Enum.sort_by(acc, &elem(&1, 1), &>=/2)
      |> Stream.take(5)
      |> Enum.map(&elem(&1, 0))
      |> List.to_string()
    if checksum == check, do: String.to_integer(id), else: 0
  end
  defp do_check(<<?-, t::binary>>, acc) do
    do_check(t, acc)
  end
  defp do_check(<<h, t::binary>>, acc) do
    do_check(t, Map.update(acc, h, 1, &(&1 + 1)))
  end

  @doc """
  Decrypt the input.

  iex> AOC2016.Day4.decrypt("qzmt-zixmtkozy-ivhz-343")
  {"343", "very encrypted name"}
  """
  def decrypt(input) do
    [_, cipher, id] = Regex.run(~r/(.*)-(\d{3})/, input)
    do_decrypt(cipher, rem(String.to_integer(id), 26), id, <<>>)
  end

  defp do_decrypt(<<>>, _, id, acc) do
    {id, acc}
  end
  defp do_decrypt(<<?-, t::binary>>, n, id, acc) do
    do_decrypt(t, n, id, acc <> " ")
  end
  defp do_decrypt(<<h, t::binary>>, n, id, acc) do
    h = if h + n > ?z, do: h + n - 26, else: h + n
    do_decrypt(t, n, id, acc <> <<h>>)
  end
end
