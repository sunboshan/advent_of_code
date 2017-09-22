defmodule AOC2016.Day14 do
  @moduledoc """
  Day 14: One-Time Pad

  Use a queue to track the calculated hash. Use a list `pentas` to track
  all the potential five-of-a-kind hashes.

    - calcuate first 1000 hashes, get the hash_queue and pentas list
    - starting on index 1000
    - get the index (1000 - n)'s hash from head of hash_queue
    - add current index's hash to hash_queue
    - update the pentas list if the current hash contains five-of-a-kind
    - check each hash if they contains triplet
      - if not, just move on
      - if so, check the current pentas list to see if it's the key
        - if so, add the hash to the keys list
        - if not, just move on
    - stop when find 64 keys
  """

  def run0 do
    salt = "abc"
    hash_fun = &:crypto.hash(:md5, &1)
    run(salt, hash_fun)
    |> hd()
  end

  def run1 do
    salt = "qzyelonm"
    hash_fun = &:crypto.hash(:md5, &1)
    run(salt, hash_fun)
    |> hd()
  end

  def run2 do
    salt = "qzyelonm"
    hash_fun = &hash2017/1
    run(salt, hash_fun)
    |> hd()
  end

  def run(salt, hash_fun) do
    {hash_queue, pentas} = init(salt, hash_fun)
    find_keys(1000, salt, hash_fun, hash_queue, pentas, [])
  end

  @doc """
  Hash the string 2017 times.
  """
  @spec hash2017(String.t) :: binary
  def hash2017(str) do
    Enum.reduce(1..2017, str, fn _, acc ->
      :crypto.hash(:md5, acc)
      |> Base.encode16(case: :lower)
    end)
    |> Base.decode16!(case: :lower)
  end

  @doc """
  Calculate first 1000 hashes to get hash_queue and pentas list.
  """
  @spec init(String.t, (String.t -> binary)) :: {:queue.queue, list}
  def init(salt, hash_fun) do
    Enum.reduce(0..999, {:queue.new(), []}, fn n, {hash_queue, pentas} ->
      hash = hash_fun.("#{salt}#{n}")
      {:queue.in(hash, hash_queue), check_penta(hash, n, pentas)}
    end)
  end

  @doc """
  Find keys according to the algorithm described in moduledoc.
  """
  def find_keys(_, _, _, _, _, keys) when length(keys) == 64 do
    keys
  end
  def find_keys(n, salt, hash_fun, hash_queue, pentas, keys) do
    hash = hash_fun.("#{salt}#{n}")
    hash_queue = :queue.in(hash, hash_queue)
    pentas = check_penta(hash, n, pentas)
    {{:value, hash}, hash_queue} = :queue.out(hash_queue)
    keys = check_key(hash, n - 1000, pentas, keys)
    find_keys(n + 1, salt, hash_fun, hash_queue, pentas, keys)
  end

  @doc """
  Check if a hash has five-of-a-kind.
  """
  @spec check_penta(binary, integer, list) :: list
  def check_penta(<<>>, _, acc), do: acc
  def check_penta(<<h::4, h::4, h::4, h::4, h::4, _::bits>>, n, acc) do
    [{n, h} | acc]
  end
  def check_penta(<<_::4, t::bits>>, n, acc) do
    check_penta(t, n, acc)
  end

  @doc """
  Check if a hash has triplet.
  """
  @spec check_key(binary, integer, list, list) :: list
  def check_key(<<>>, _, _, keys), do: keys
  def check_key(<<h::4, h::4, h::4, _::bits>>, n, pentas, keys) do
    (for {k, ^h} <- pentas, do: k)
    |> Enum.find(fn k -> k > n end)
    |> (if do: [n | keys], else: keys)
  end
  def check_key(<<_::4, t::bits>>, n, pentas, keys) do
    check_key(t, n, pentas, keys)
  end
end
