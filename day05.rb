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
def execute(state)
  memory = state[:memory].dup
  pos = state[:pos]
  instr = parse_instruction(memory[pos])

  a = memory[pos + 1]
  b = memory[pos + 2]
  c = memory[pos + 3]

  v1 = resolve_argument(a, 1, memory, instr)
  v2 = resolve_argument(b, 2, memory, instr)

  new_pos = pos
  halted = false

  if instr[:opcode] == '01'
    puts "memory[#{c}] = #{v1} + #{v2}"
    memory[c] = v1 + v2
    new_pos += 4

  elsif instr[:opcode] == '02'
    puts "memory[#{c}] = #{v1} * #{v2}"
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

  elsif instr[:opcode] == '99'
    halted = true
  else
    raise "dunno what to do with #{instr[:opcode]}"
  end

  return {
    memory: memory,
    pos: new_pos,
    halted: halted
  }
end

def run_until_halt(ints)
  state = { memory: ints.dup, pos: 0, halted: false }

  while state[:halted] != true
    state = execute(state)
  end

  state
end

run_until_halt(ints)
