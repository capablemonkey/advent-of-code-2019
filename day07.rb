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

class Amp
  attr_accessor :state

  def initialize(ints)
    @memory = ints.dup
    @pos = 0
    @state = :running
    @last_output = nil
  end

  def step
    raise "still awaiting input" if @state == :awaiting_input
    raise "halted" if @state == :halted

    instr = parse_instruction(@memory[@pos])

    a = @memory[@pos + 1]
    b = @memory[@pos + 2]
    c = @memory[@pos + 3]

    v1 = instr[:args_immediate][1] ? a : @memory[a || 0]
    v2 = instr[:args_immediate][2] ? b : @memory[b || 0]

    @state = :running

    if instr[:opcode] == '01'
      @memory[c] = v1 + v2
      @pos += 4

    elsif instr[:opcode] == '02'
      @memory[c] = v1 * v2
      @pos += 4

    elsif instr[:opcode] == '03'
      @state = :awaiting_input
      @input_dest = a

    elsif instr[:opcode] == '04'
      @pos += 2
      @state = :output
      @last_output = v1

    elsif instr[:opcode] == '05'
      if v1 != 0
        @pos = v2
      else
        @pos += 3
      end

    elsif instr[:opcode] == '06'
      if v1 == 0
        @pos = v2
      else
        @pos += 3
      end

    elsif instr[:opcode] == '07'
      @memory[c] = v1 < v2 ? 1 : 0
      @pos += 4

    elsif instr[:opcode] == '08'
      @memory[c] = v1 == v2 ? 1 : 0
      @pos += 4

    elsif instr[:opcode] == '99'
      @state = :halted
    else
      raise "not sure what to do #{instr[:opcode]}"
    end

    {
      state: @state,
      output: @last_output
    }
  end

  def give_input(input)
    @memory[@input_dest] = input
    @pos += 2
    @state = :running
  end

  def ack_output
    raise "not in output state" unless @state == :output
    @state = :running
    true
  end

  def step_until_event
    result = {state: @state}

    while @state == :running
      result = step
    end

    result
  end
end

def run_sequence(ints, sequence)
  last_output = 0

  sequence.each do |p|
    a = Amp.new(ints)
    a.step_until_event
    a.give_input(p)
    a.step_until_event
    a.give_input(last_output)
    event = a.step_until_event
    last_output = event[:output]
  end

  last_output
end

def part1(ints)
  results = [0,1,2,3,4].permutation(5).map do |seq|
    run_sequence(ints, seq)
  end

  ap "max: #{results.reject(&:nil?).max}"
end

def run_sequence_continuous(ints, sequence)
  # general algorithm:
  # 0. Initialize all the amplifiers with the sequence; send first signal (0)
  # 1. Run current program until state is :awaiting_input, :output, or :halted
  # 2. If state is awaiting input, call give_input with output from previous amp
  # 3. If state is output, move on to the next amp
  # 4. If state is halted, and the current amp is the last amp in the chain (E),
  #     then return its output. Otherwise, move on to the next amp.

  amps = sequence.map do |v|
    a = Amp.new(ints)
    r = a.step_until_event

    if a.state != :awaiting_input
      raise "not in the right state for initialization"
    end

    a.give_input(v)
    a
  end

  loop_end = false
  last_output = 0
  current = amps.first
  current_idx = 0

  while !loop_end
    event = current.step_until_event

    if event[:state] == :awaiting_input
      current.give_input(last_output)
    elsif event[:state] == :output
      last_output = event[:output]
      current.ack_output

      current_idx = (current_idx + 1) % amps.size
      current = amps[current_idx]
    elsif event[:state] == :halted
      return event[:output] if current_idx == amps.size - 1

      current_idx = (current_idx + 1) % amps.size
      current = amps[current_idx]
    end
  end

  last_output
end

def part2(ints)
  results = [5,6,7,8,9].permutation(5).map do |seq|
    run_sequence_continuous(ints, seq)
  end

  ap "max: #{results.reject(&:nil?).max}"
end

part1(ints)

# test_ints = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
# run_sequence_continuous(test_ints, [9,8,7,6,5])
part2(ints)