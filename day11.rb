require 'ap'

input_lines = File.new('input/day-11.txt').readlines
ints = input_lines[0].split(',').map(&:to_i)

ARG_MODES = {
  '0' => :address,
  '1' => :immediate,
  '2' => :relative
}

def parse_instruction(instr)
  padded = instr.to_s.rjust(5, '0')

  return {
    opcode: padded[3..-1],
    arg_modes: {
      0 => ARG_MODES[padded[2]],
      1 => ARG_MODES[padded[1]],
      2 => ARG_MODES[padded[0]]
    }
  }
end

class Amp
  attr_accessor :state

  def initialize(ints)
    # right pad memory with 0s up to 10,000:
    @memory = ints.dup.concat(Array.new(1_000_000 - ints.size, 0))
    @pos = 0
    @state = :running
    @last_output = nil
    @base_address = 0
  end

  def step
    raise "still awaiting input" if @state == :awaiting_input
    raise "halted" if @state == :halted

    instr = parse_instruction(@memory[@pos])

    # ap "intcode: #{@memory[@pos]}"

    a = @memory[@pos + 1]
    b = @memory[@pos + 2]
    c = @memory[@pos + 3]

    v1 = resolve_argument(a, instr[:arg_modes][0])
    v2 = resolve_argument(b, instr[:arg_modes][1])
    v3 = resolve_address(c, instr[:arg_modes][2])

    @state = :running

    if instr[:opcode] == '01'
      @memory[v3] = v1 + v2
      @pos += 4

    elsif instr[:opcode] == '02'
      @memory[v3] = v1 * v2
      @pos += 4

    elsif instr[:opcode] == '03'
      @state = :awaiting_input
      @input_dest = resolve_address(a, instr[:arg_modes][0])

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
      @memory[v3] = v1 < v2 ? 1 : 0
      @pos += 4

    elsif instr[:opcode] == '08'
      @memory[v3] = v1 == v2 ? 1 : 0
      @pos += 4

    elsif instr[:opcode] == '09'
      @base_address += v1
      @pos += 2

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

  private

    def resolve_argument(value, mode)
      return value if mode == :immediate
      @memory[resolve_address(value, mode)]
    end

    def resolve_address(value, mode)
      return @base_address + value if mode == :relative
      value || 0
    end
end

def part1(ints)
  cells = Hash.new {|h,k| h[k] = 0}
  cells[[0,0]] = 1
  x = 0
  y = 0
  directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  direction_idx = 0

  a = Amp.new(ints)

  i = 0
  while (i+=1) < 100000
    ap cells.keys.size
    value = cells[[x,y]]
    a.step_until_event
    a.give_input(value)

    event = a.step_until_event
    a.ack_output
    ap event
    color = event[:output]
    cells[[x,y]] = color

    event2 = a.step_until_event
    a.ack_output
    ap event2
    turn_right = event2[:output]

    direction_idx = (direction_idx + (turn_right == 1 ? 1 : -1)) % 4
    direction = directions[direction_idx]
    x += direction[0]
    y += direction[1]
  end
rescue
  puts cells.keys.map {|x,y| "(#{x},#{y})"}.join(",")
  plot_points(cells)
end

def plot_points(points_hash)
  graph = Array.new(50) {  Array.new(50) { 0 } }
  points_hash.keys.each do |x,y|
    graph[y+10][x] = points_hash[[x,y]]
  end
  puts graph.map { |r| r.join('')}.join("\n")
end

part1(ints)
