defmodule AOC2016.Day16 do
  @moduledoc """
  Day 16: Dragon Checksum

  The normal way to calculate the checksum for part two takes forever to run.
  The algorithm used here is to calculate the dragon bits parity in O(logN).

  - the part one is calculated around 100us
  - the part two is calculated around 300us

  For example, a 24 bits(0b11000) checksum will reduce to 3(0b11) bits,
  each bit is reduced by 8 bits(0b1000) block.

        block 0       block 1       block 2
      10 00 00 11   11 00 10 00   01 11 10 11
       0 1   1 1     1 1   0 1     0 1   0 1
         0   1         1   0         0   0
           0             0             1

  Also, each checksum bit can be calculated by the parity of each block.

    - if block contains odd  number of 1s, it's 0
    - if block contains even number of 1s, it's 1

  Then calculate the checksum mounts as calculate the parity of each block.

  The dragon curve for any input a(10000) can be calculated as following:

      a = 10000
      b = 11110 (a's negate and reverse)

      a 0 b 0 a 1 b 0 a 0 b 1 a 1 b 0 ...   # dragon curve

  Now take a, b out, the joiner bit itself is a dragon curve

      0 0 1 0 0 1 1 0 ...

  For dragon bits at any index, it can be calculated in O(1). Check
  the function doc for more detail.

  Then the parity of accumulated dragon bits can be calculated in O(logN).
  Check the function doc for more detail.
  """

  import Bitwise

  def run0 do
    <<0b10000::5>>
    |> checksum(20)
  end

  def run1 do
    <<0b11100010111110100::17>>
    |> checksum(272)
  end

  def run2 do
    <<0b11100010111110100::17>>
    |> checksum(35651584)
  end

  @doc """
  Calculate checksum in O(logN).
  """
  def checksum(input, len) do
    block_size = len &&& -len
    pattern = <<input::bits, 0::1, neg_rev(input)::bits, 0::1>>
    Enum.to_list(1..div(len, block_size))
    |> do_checksum(block_size, pattern, bit_size(input), <<>>, 0, [])
  end

  defp do_checksum([], _, _, _, _, _, acc) do
    Enum.reverse(acc)
    |> Enum.join()
  end
  defp do_checksum([i | t], block_size, pattern, n, left, last_dp, acc)
      when block_size >= bit_size(left) do
    dp = dragon_parity(div(block_size * i, n + 1))
    pairs = div(block_size - bit_size(left), (n + 1) * 2)
    r = rem(block_size - bit_size(left), (n + 1) * 2)
    <<right::bits-size(r), reminder::bits>> = pattern
    c = p(n) &&& p(pairs) ^^^ parity(left) ^^^ parity(right) ^^^ last_dp ^^^ dp ^^^ 1
    do_checksum(t, block_size, pattern, n, reminder, dp, [c | acc])
  end
  defp do_checksum([i | t], block_size, pattern, n, left, last_dp, acc) do
    dp = dragon_parity(div(block_size * i, n + 1))
    <<right::bits-size(block_size), reminder::bits>> = left
    c = parity(right) ^^^ last_dp ^^^ dp ^^^ 1
    do_checksum(t, block_size, pattern, n, reminder, dp, [c | acc])
  end

  @doc """
  Negate and reverse the bits.

      iex> AOC2016.Day16.neg_rev(<<0b10000::5>>)
      <<0b11110::5>>
      iex> AOC2016.Day16.neg_rev(<<0b11100010111110100::17>>)
      <<0b11010000010111000::17>>
  """
  @spec neg_rev(bitstring) :: bitstring
  def neg_rev(<<>>), do: <<>>
  def neg_rev(<<h::1, t::bits>>), do: <<neg_rev(t)::bits, (h ^^^ 1)::1>>

  @doc """
  If integer is odd, the parity is 1, otherwise is 0.
  """
  @spec p(integer) :: 0 | 1
  def p(integer) when rem(integer, 2) == 1, do: 1
  def p(_), do: 0

  @doc """
  Caculate the parity of number of 1s in bitstring.
  """
  @spec parity(bitstring) :: 0 | 1
  def parity(<<>>), do: 0
  def parity(<<h::1, t::bits>>), do: h ^^^ parity(t)

  @doc """
  Calculate the dragon bits in O(1) time.

  Here's an example of dragon bits. Take a closer look, we can see it can be
  build in this way:

  index 0 1 2 3 4 5 6 7 ...
        0 0 1 0 0 1 1 0 ...

  - for every even index, it's 0, 1 in turns
  - for every odd index, the value is same as index (i - 1) / 2

  For example, for an index i 303(0b100101111):
    - it  is odd,  so the index is same as (303 - 1) / 2 = 151  0b10010111
    - 151 is odd,  so the index is same as (151 - 1) / 2 = 75   0b1001011
    - 75  is odd,  so the index is same as (75 - 1)  / 2 = 37   0b100101
    - 37  is odd,  so the index is same as (37 - 1)  / 2 = 18   0b10010
    - 18 is even, since it's 0, 1 in turns, so is same as 0b10, which is 1
  """
  @spec dragon_bits(integer) :: 0 | 1
  def dragon_bits(n) do
    div(n, ((n + 1) ^^^ n) + 1) &&& 1
  end

  @doc """
  Calculate the accumulated dragon bits parity in O(logN) time.

  Here's first 64 bits of dragon bits, calculate their accumulated parity:

      0010011000110110001001110011011000100110001101110010011100110110  # dragon bits
      0011101111011011110001011101101111000100001001011100010111011011  # acc parity

  Split the parity in four parts:

      0011101111011011 1100010111011011
      1100010000100101 1100010111011011
                     ^
  We can see, the part II and IV are same; the part I and III are xor except
  for last bit.

  Keep split part I and II:

      00111011 11011011
      11000101 11011011
             ^
  Same property holds true. Keep splitting:

      0011 1011
      1101 1011
         ^

      00 11
      10 11
       ^

  As we can see, the property holds true except for last 4 bits.

      0 0
      1 1

  If we look at the binary of any index, it has following property:

  - 00xxxx -> 0xxxx          # part I stays same
  - 01xxxx -> 1xxxx          # part II stays same
  - 11xxxx -> 1xxxx          # part IV is same as part II
  - 10xxxx
    - 101111 -> 0xxxx        # part III's last bit stays same as part I's last bit
    - 10xxxx -> 0xxxx xor 1  # part III's rest bits are xored with part I's bits

  Based on this property, we can calculate the parity of accumulated dragon bits
  in O(logN).
  """
  @spec dragon_parity(integer) :: 0 | 1
  def dragon_parity(n) when n > 0 do
    Integer.to_string(n - 1, 2)
    |> do_dragon_parity(0)
  end
  def dragon_parity(_), do: 0

  def do_dragon_parity(<<_>>, _), do: 0
  def do_dragon_parity(<<n, _>>, acc), do: (n - ?0) ^^^ acc
  def do_dragon_parity(<<?1, ?0, t::binary>>, acc) do
    if Regex.match?(~r/^1+$/, t),
      do:   do_dragon_parity(<<?0, t::binary>>, acc),
      else: do_dragon_parity(<<?0, t::binary>>, acc ^^^ 1)
  end
  def do_dragon_parity(<<_, t::binary>>, acc), do: do_dragon_parity(t, acc)
end
