require 'ap'

def adjacent_digits?(n)
  str = n.to_s

  str.each_char.with_index do |num, i|
    return true if num == str[i + 1]
  end

  false
end

def increasing?(n)
  str = n.to_s

  str.each_char.with_index do |num, i|
    return false if str[i + 1] && (num.to_i > str[i + 1].to_i)
  end

  true
end

def strict_adjacent_digits?(n)
  str = n.to_s
  streaks = str.each_char.slice_when {|a, b| a != b}.map(&:size)

  return true if streaks.select {|x| x >= 2}.min == 2

  false
end

def part1(a, b)
  (a..b).map {|n| adjacent_digits?(n) && increasing?(n) }.count(true)
end

def part2(a, b)
  (a..b).map {|n| increasing?(n) && strict_adjacent_digits?(n)}.count(true)
end

a = 236491
b = 713787
puts part1(a, b)
puts part2(a, b)