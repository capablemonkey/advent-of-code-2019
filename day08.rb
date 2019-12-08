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
  min_l = layers.min_by {|l| l.flatten.count(0) }
  result = min_l.flatten.count(1) * min_l.flatten.count(2)

  ap result
end

def merge_layers(a, b, width, height)
  flat_merged = a.flatten.zip(b.flatten).map do |a,b|
    a == 2 ? b : a
  end

  layers(flat_merged, width, height)
end

def print_image(layer)
  puts layer.map {|l| l.join('')}.join("\n")
end

def part2(data, width, height)
  layers = layers(data, width, height)
  merged = layers.reduce {|a, b| merge_layers(a, b, width, height)}
  print_image(merged[0])
end

data = input_lines[0].split("").map(&:to_i)
# part1("123456789012".split("").map(&:to_i), 3, 2)
# part2("0222112222120000".split("").map(&:to_i), 2, 2)
part1(data, 25, 6)
part2(data, 25, 6)