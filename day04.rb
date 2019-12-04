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
    next if str[i + 1] == nil
    return false if num.to_i > str[i + 1]&.to_i
  end

  true
end

def valid?(n)
  adjacent_digits?(n) && increasing?(n)
end

def part1
  a = 236491
  b = 713787

  (a..b).map {|n| valid?(n)}.select {|x| x==true}.count
end

def strict_adjacent_digits?(n)
  str = n.to_s
  streak = 1

  streaks = []

  str.each_char.with_index do |num, i|
    if num == str[i + 1]
      streak += 1
    else
      streaks.push(streak)
      streak = 1
    end
  end

  # ap streaks

  return true if streaks.select {|x| x >= 2}.min == 2

  false
end

def part2
  a = 236491
  b = 713787

  (a..b).map {|n| increasing?(n) && strict_adjacent_digits?(n)}.select {|x| x==true}.count
end

# puts adjacent_digits?(223450)
# puts adjacent_digits?(213450)
# puts increasing?(1234)
# puts increasing?(12340)

# puts strict_adjacent_digits?(112233)
# puts strict_adjacent_digits?(123444)
# puts strict_adjacent_digits?(111122)


puts part1
puts part2