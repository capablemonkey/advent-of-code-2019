input_lines = File.new('input/day-02.txt').readlines
ints = input_lines[0].split(',').map(&:to_i)

# given ints, execute instruction at pos and return new state
def execute(ints, pos)
  memory = ints.dup
  opcode = ints[pos]
  a = memory[pos + 1]
  b = memory[pos + 2]
  c = memory[pos + 3]

  if opcode == 1
    memory[c] = memory[a] + memory[b]
  elsif opcode == 2
    memory[c] = memory[a] * memory[b]
  else
    raise "dunno what to do"
  end

  return memory
end

def run_until_halt(ints)
  memory = ints.dup
  pos = 0

  while memory[pos] != 99
    memory = execute(memory, pos)
    pos += 4
  end

  memory
end

def evaluate(ints, noun, verb)
  memory = ints.dup
  memory[1] = noun
  memory[2] = verb
  run_until_halt(memory)[0]
end

def part1(ints)
  puts evaluate(ints, 12, 2)
end

def part2(ints, target_output)
  (0..99).to_a.permutation(2).each do |noun, verb|
    result = evaluate(ints, noun, verb)

    if result == target_output
      puts "noun: #{noun}, verb: #{verb}, result: #{result}"
      puts "answer: #{100 * noun + verb}"
      return
    end
  end
end

# part1([1,1,1,4,99,5,6,0,99])
part1(ints)
part2(ints, 19690720)