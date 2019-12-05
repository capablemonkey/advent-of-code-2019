def adjacent_digits?(n)
  n.to_s.each_char.each_cons(2) do |a, b|
    return true if a == b
  end

  false
end

def increasing?(n)
  n.to_s.each_char.each_cons(2) do |a, b|
    return false if a > b
  end

  true
end

def strict_adjacent_digits?(n)
  streaks = n.to_s.each_char.slice_when {|a, b| a != b}.map(&:size)
  return true if streaks.select {|x| x >= 2}.min == 2

  false
end

def part1(a, b)
  (a..b).count { |n| increasing?(n) && adjacent_digits?(n) }
end

def part2(a, b)
  (a..b).count { |n| increasing?(n) && strict_adjacent_digits?(n) }
end

puts part1(236491, 713787)
puts part2(236491, 713787)