defmodule AOC2016.Day19 do
  @moduledoc """
  Day 19: An Elephant Named Joseph

  - part 1 is Josephus problem, watch https://youtu.be/uCsD3ZGzMgE for detail
  - part 2 use two queues to form a ring

  Both part has O(1) solution. Here include both the naive solution and O(1)
  solution.
  """

  import Bitwise

  def run1 do
    steal(3_004_953)
  end

  def run1_o1 do
    steal_o1(3_004_953)
  end

  def run2 do
    steal2(3_004_953)
  end

  def run2_o1 do
    steal2_o1(3_004_953)
  end

  @doc """
  Naive implementation for part 1 in O(logN).

  Here's the algorithm:

      # first round we always steal from even position, then we can set a flag
      # to indicate how many elf left
      1 2 3 4 5 6 7 8 9
        x   x   x   x

      # if the flag is 1, then we steal from odd position
      # else, we still steal from even position
      # in this case, we steal from odd, and set flag to 0
      1 3 5 7 9
      x   x   x

      # now we steal from even, flag is still 0
      3 7
        x

      # here's our winner
      3

  Look at the flag operation with parity of current round:

      flag  parity  new_flag
       0     even      0
       1     even      1
       0     odd       1
       1     odd       0

  It is in fact xor.

  For number of elves left in the next round, it depends on our flag:

      flag       next_round
       0      ceil(current / 2)
       1     floor(current / 2)

  The flag is our winner's bit in that round, so after we are done, all bits
  in the flag is the winner's zero-based index, so their number is index + 1.
  """
  @spec steal(pos_integer) :: pos_integer
  def steal(1), do: 1
  def steal(input) when input > 0 do
    do_steal(input, 0, [0])
  end

  defp do_steal(1, _, [_ | t]) do
    Enum.join(t)
    |> String.to_integer(2)
    |> Kernel.+(1)
  end
  defp do_steal(input, flag, acc) do
    parity = input &&& 1
    input = case flag do
      0 -> (input + 1) >>> 1
      1 -> input >>> 1
    end
    flag = flag ^^^ parity
    do_steal(input, flag, [flag | acc])
  end

  @doc """
  This is a very cool trick according to the Josephus problem video.
  Just move the MSB to LSB and we are done.

  For example:

      1100110   # input
       1001101  # solution
  """
  @spec steal_o1(pos_integer) :: pos_integer
  def steal_o1(input) when input > 0 do
    n = Stream.iterate(input, &(&1 >>> 1))
      |> Enum.find_index(&(&1 == 1))
    ((input - (1 <<< n)) <<< 1) + 1
  end

  @doc """
  Naive implementation for part 2 in O(N). Use two queues to form a ring.
  Run time around 1.7s.

  Here's the algorithm:

      # starting with two queues, one first half, one second half
      [1, 2, 3, 4]
      [5, 6, 7, 8]

      # move head of queue1 to tail of queue2, also remove head of queue2
      [2, 3, 4]
      [6, 7, 8, 1]

      # same step one more time
      [3, 4]
      [7, 8, 1, 2]

      # when queue2 is 2 items more than queue1, we need to balance the queues
      [3, 4, 7]
      [8, 1, 2]

      ...

      [7]
      [2]

      []
      [7]  # here we get our winner
  """
  @spec steal2(pos_integer) :: pos_integer
  def steal2(1), do: 1
  def steal2(input) when input > 0 do
    half = div(input, 2)
    queue1 = Enum.to_list(1..half)
      |> :queue.from_list()
    queue2 = Enum.to_list((half + 1)..input)
      |> :queue.from_list()
    do_steal2(queue1, queue2, rem(input, 2))
  end

  defp do_steal2({[], []}, {[n], []}, _), do: n
  defp do_steal2(queue1, queue2, 2) do
    {{:value, v}, queue2} = :queue.out(queue2)
    queue1 = :queue.in(v, queue1)
    do_steal2(queue1, queue2, 0)
  end
  defp do_steal2(queue1, queue2, n) do
    {{:value, v}, queue1} = :queue.out(queue1)
    queue2 = :queue.drop(queue2)
    queue2 = :queue.in(v, queue2)
    do_steal2(queue1, queue2, n + 1)
  end

  @doc """
  After output first 100 result for `steal2/1`, we can see a pattern like this:

      {1, 1}     # reset to 1 next
      {2, 1}
      {3, 3}     # reset to 1 next
      {4, 1}
      {5, 2}
      {6, 3}
      {7, 5}
      {8, 7}
      {9, 9}     # reset to 1 next
      {10, 1}
      {11, 2}
      {12, 3}
      {13, 4}
      {14, 5}
      {15, 6}
      {16, 7}
      {17, 8}
      {18, 9}    # result is increased by 1
      {19, 11}
      {20, 13}
      {21, 15}
      {22, 17}
      {23, 19}
      {24, 21}
      {25, 23}
      {26, 25}   # result is increased by 2
      {27, 27}   # reset to 1 next
      {28, 1}
      {29, 2}
      {30, 3}
      {31, 4}
      {32, 5}

  The winner reset to 1 after power of 3, and the 1st half increased by 1,
  2nd half increased by 2.
  """
  @spec steal2_o1(pos_integer) :: pos_integer
  def steal2_o1(1), do: 1
  def steal2_o1(input) when input > 0 do
    n = Stream.iterate(1, &(&1 * 3))
      |> Enum.find(&(&1 >= input))
      |> div(3)
    case input do
      i when i <= 2 * n -> i - n
      i                 -> i - n + i - n * 2
    end
  end
end
