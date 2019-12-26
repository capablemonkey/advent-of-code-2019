require 'ap'

input_lines = File.new('input/day-16.txt').readlines

def pattern(length, repeats)
  base_pattern = [0, 1, 0, -1].freeze
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
  (0...n).reduce(input) {|acc, idx| puts idx; phase(acc) }
end

def part1(input)
  output = transform(input, 100)
  ap output[0...8].join('')
end

# only works on last half of the original input
def phase_fast(input)
  output = []
  partial_sum = 0
  input.reverse.each do |digit|
    partial_sum += digit
    output.unshift(partial_sum % 10)
  end

  output
end

def part2(input)
  repeated_input = input * 10_000
  offset = input[0...7].join("").to_i
  ap "offset #{offset}"

  relevant_part = repeated_input[offset..-1]
  output = (0...100).reduce(relevant_part) {|acc, idx| puts idx; phase_fast(acc) }

  ap output[0...8].join('')
end

input = input_lines[0].strip.each_char.map(&:to_i)

# part1(input)
part2(input)
