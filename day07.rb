require 'ap'

input_lines = File.new('input/day-07.txt').readlines
ints = input_lines[0].split(',').map(&:to_i)

def parse_instruction(instr)
  padded = instr.to_s.rjust(5, '0')

  return {
    opcode: padded[3..-1],
    args_immediate: {
      1 => padded[2] == '1',
      2 => padded[1] == '1',
      3 => padded[0] == '1'
    }
  }
end

def run_until_halt(ints)
  memory = ints.dup
  pos = 0
  halted = false
  input_counter = 0

  while halted != true
    instr = parse_instruction(memory[pos])

    a = memory[pos + 1]
    b = memory[pos + 2]
    c = memory[pos + 3]

    v1 = instr[:args_immediate][1] ? a : memory[a]
    v2 = instr[:args_immediate][2] ? b : memory[b]

    if instr[:opcode] == '01'
      memory[c] = v1 + v2
      pos += 4

    elsif instr[:opcode] == '02'
      memory[c] = v1 * v2
      pos += 4

    elsif instr[:opcode] == '03'
      input = yield(input_counter) # part  2
      input_counter += 1
      memory[a] = input
      pos += 2

    elsif instr[:opcode] == '04'
      return v1
      pos += 2

    elsif instr[:opcode] == '05'
      if v1 != 0
        pos = v2
      else
        pos += 3
      end

    elsif instr[:opcode] == '06'
      if v1 == 0
        pos = v2
      else
        pos += 3
      end

    elsif instr[:opcode] == '07'
      memory[c] = v1 < v2 ? 1 : 0
      pos += 4

    elsif instr[:opcode] == '08'
      memory[c] = v1 == v2 ? 1 : 0
      pos += 4

    elsif instr[:opcode] == '99'
      halted = true
    else
      raise "not sure what to do #{opcode}"
    end
  end
end

def run_with_params(ints, params)
  output = run_until_halt(ints) do |i|
    # puts "asking for input #{i} = #{params[i]}"
    params[i]
  end

  output
end

def run_sequence(ints, sequence)
  last_output = 0

  sequence.map do |v|
    last_output = run_with_params(ints, [v, last_output])
    # puts "output #{last_output}"
    last_output
  end

  last_output
end

def part1(ints)
  results = (00000..44444).map do |i|
    padded = i.to_s.rjust(5, '0').split('').map(&:to_i)
    next unless padded.uniq == padded
    next unless padded.all? {|d| d < 5}
    ap padded
    run_sequence(ints, padded)
  end

  ap results.reject(&:nil?).max
end

part1(ints)