require 'ap'

input_lines = File.new('input/day-08.txt').readlines

def layers(data, width, height)
  data.
    each_slice(width).
    each_slice(height).
    to_a
end

def part1(data, width, height)
  layers = layers(data, width, height)

  ap layers

  min_l = layers.min_by {|l| l.flatten.count(0) }

  result = min_l.flatten.count(1) * min_l.flatten.count(2)

  ap result
end

# part1("123456789012".split("").map(&:to_i), 3, 2)
data = input_lines[0].split("").map(&:to_i)
part1(data, 25, 6)