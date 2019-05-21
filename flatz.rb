#!/usr/bin/env ruby
# frozen_string_literal: true

require 'time'

if ARGV[0].nil?
  puts 'Usage: flatz.rb (test|ARRAY)'
  puts '       ARRAY is a comma delimited list of integers.'
  puts '       Use square brackets to nest another array.'
  puts '       For example, flatz.rb [1,2,[3,4],5,[6,7,8]]'
  exit
end

input = ARGV[0]

conditions = [
  [[1], [[[[[1]]]]]],
  [[1, 2, 3, 4], [1, 2, 3, 4]],
  [[-1, 0, 1, 2, 3, 4], [-1, 0, 1, 2, 3, 4]],
  [[1, 2, 3, 4], [1, [2, [3], 4]]],
  [[1, 2, 3, 4, 5, 6, 7, 8], [1, 2, [3, 4], 5, [6, 7, 8]]],
  [[1, 2, 3, 4, 5, 6, 7, 8], [[1, 2, [3, 4], 5, [6, 7, 8]]]],
  [[1, 2, 3, 4, 5], [[1], [2], [[3], [4, 5]]]],
  [nil, nil]
]

def do_test(expected, actual)
  return if expected.nil? && actual.nil?

  if expected.size != actual.size
    throw " [x] Test failed! Expected #{expected} but got #{actual}"
  end

  (0..expected.size - 1).each do |i|
    if expected[i] != actual[i]
      throw " [x] Test failed! Expected #{expected} but got #{actual}"
    end
  end
end

def flatz(arr)
  return arr if arr.nil?

  result = []

  arr.each do |element|
    if element.is_a?(Array)
      result.concat(flatz(element))
    else
      result << element
    end
  end

  result
end

def scan(str)
  result = []

  str.scan(/((-?\d+)|(\[(.+)\]))/).each do |match|
    if match[1]
      result << match[1].to_i
    elsif match[3]
      result << scan(match[3])
    end
  end

  result
end

def timed(&block)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  block.call
  finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  puts format(' [o] Took %<duration>0.6f seconds.', duration: (finish - start))
end

def test(conditions)
  puts " [o] #{Time.now} - Starting..."

  conditions.each do |result, input|
    do_test(result, flatz(input))
  end

  big = Array.new(10_000_000) { |i| i }
  puts format(' [o] Testing array of size %<size>d', size: big.size)
  timed do
    do_test(big, flatz(big))
  end

  puts " [o] #{Time.now} - Done."
end

if input == 'test'
  test(conditions)
else
  parsed = scan(input)
  result = flatz(parsed)
  puts result.to_s
end
