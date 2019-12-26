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

def phase_fast(input)
  output = []

  (0...input.size).each do |digit_idx|
    # ap "digit idx #{digit_idx }"
    sum = 0
    cursor = digit_idx
    chunk_size = digit_idx + 1
    sign = 1

    while cursor < input.size do
      chunk = input[cursor...(cursor+chunk_size > input.size ? input.size : cursor+chunk_size)]
      # ap "chunk: #{chunk}"
      sum += (chunk.sum * sign)
      sign = sign * -1

      cursor += (2 * chunk_size)
    end

    output.push(sum.abs % 10)
  end

  output
end

def transform(input, n)
  (0...n).reduce(input) {|acc, idx| puts idx;phase_fast(acc) }
end

def part1(input)
  output = transform(input, 100)
  ap output[0...8].join('')
end

def part2(input)
  repeated_input = input * 10_000
  output = transform(repeated_input, 100)
  ap output[0...8].join('')
end

input = input_lines[0].strip.each_char.map(&:to_i)
# input = "12345678".strip.each_char.map(&:to_i)

# ap phase_fast(input)

# part1(input)
part2(input)