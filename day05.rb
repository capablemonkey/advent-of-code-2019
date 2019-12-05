require 'ap'

input_lines = File.new('input/day-05.txt').readlines
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

def resolve_argument(value, arg_num, memory, instruction)
  return value if instruction[:args_immediate][arg_num]

  memory[value]
end

# given ints, execute instruction at pos and return new state
def execute(ints, pos)
  memory = ints.dup
  instr = parse_instruction(ints[pos])

  a = memory[pos + 1]
  b = memory[pos + 2]
  c = memory[pos + 3]

  v1 = resolve_argument(a, 1, memory, instr)
  v2 = resolve_argument(b, 2, memory, instr)

  new_pos = pos

  if instr[:opcode] == '01'
    puts "#{c} = #{v1} + #{v2}"
    memory[c] = v1 + v2
    new_pos += 4

  elsif instr[:opcode] == '02'
    puts "#{c} = #{v1} * #{v2}"
    memory[c] = v1 * v2
    new_pos += 4

  elsif instr[:opcode] == '03'
    # input = 1
    input = 5
    puts "memory[#{a}] = #{input}"
    memory[a] = input
    new_pos += 2

  elsif instr[:opcode] == '04'
    puts "OUTPUT: #{v1}"
    new_pos += 2

  elsif instr[:opcode] == '05'
    if v1 != 0
      new_pos = v2
      puts "JMP #{v2}"
    else
      new_pos += 3
    end

  elsif instr[:opcode] == '06'
    if v1 == 0
      puts "JMP #{v2}"
      new_pos = v2
    else
      new_pos += 3
    end

  elsif instr[:opcode] == '07'
    memory[c] = v1 < v2 ? 1 : 0
    new_pos += 4

  elsif instr[:opcode] == '08'
    memory[c] = v1 == v2 ? 1 : 0
    new_pos += 4

  else
    raise "dunno what to do with #{instr[:opcode]}"
  end

  return {
    memory: memory,
    new_pos: new_pos
  }
end

def run_until_halt(ints)
  memory = ints.dup
  pos = 0

  while memory[pos] != 99
    new_state = execute(memory, pos)

    memory = new_state[:memory]
    pos = new_state[:new_pos]
  end

  memory
end

run_until_halt(ints)
