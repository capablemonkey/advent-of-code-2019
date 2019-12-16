require 'ap'

input_lines = File.new('input/day-16.txt').readlines

def pattern(length, repeats)
  base_pattern = [0, 1, 0, -1]
  pattern = base_pattern.map {|digit| [digit] * repeats}.flatten

  pattern.cycle.take(length + 1)[1..-1]
end

def phase(input)
  input.map.with_index do |digit, idx|
    pattern = pattern(input.size, idx + 1)
    terms = input.zip(pattern).map {|d, p| d * p }
    (terms.sum.abs % 10)
  end
end

def transform(input, n)
  (0...n).reduce(input) {|acc, idx| phase(acc) }
end

def part1(input)
  output = transform(input, 100)
  ap output[0...8].join('')
end

input = input_lines[0].strip.each_char.map(&:to_i)
# input = "69317163492948606335995924319873".strip.each_char.map(&:to_i)

part1(input)