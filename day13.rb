require 'ap'

input_lines = File.new('input/day-13.txt').readlines
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
  cells = []
  a = Amp.new(ints)
  i = 0

  while (i+=1) < 10000
    event = a.step_until_event

    if event[:state] == :halted
      break
    end

    x = event[:output]
    a.ack_output

    event = a.step_until_event
    y = event[:output]
    a.ack_output

    event = a.step_until_event
    tile_id = event[:output]
    a.ack_output

    cells.push({x: x, y: y, tile_id: tile_id})
  end

  ap cells.select {|c| c[:tile_id] == 2}.size
  plot_points(cells)
end

def parse_initial_state(buffer)
  score_instruction = buffer.pop(3)
  score = nil

  if (score_instruction[0] == -1 && score_instruction[1] == 0)
    score = score_instruction[-1]
  end

  cells = buffer.each_slice(3).map do |slice|
    {
      x: slice[0],
      y: slice[1],
      tile_id: slice[2],
    }
  end

  {
    score: score,
    cells: cells
  }
end

def parse_state_update(state, buffer)
  score = state[:score]

  updated_cells = buffer.each_slice(3).map do |slice|
    {
      x: slice[0],
      y: slice[1],
      tile_id: slice[2],
    }
  end

  score_instructions = updated_cells.select {|uc| uc[:x] == -1 && uc[:y] == 0}
  updated_cells = updated_cells - score_instructions

  # ap "updated cells: #{updated_cells}"

  max_score = score_instructions.max_by {|i| i[:tile_id]}
  if max_score
    score = max_score[:tile_id]
  end

  cells = state[:cells].dup
  cells = cells.map do |c|
    updated_cell = updated_cells.select {|uc| c[:x] == uc[:x] && c[:y] == uc[:y]}&.last

    if updated_cell
      updated_cell
    else
      c
    end
  end

  {
    score: score,
    cells: cells
  }
end

def determine_action(cells)
  ball = cells.find {|c| c[:tile_id] == 4}
  paddle = cells.find {|c| c[:tile_id] == 3}

  if ball[:x] > paddle[:x]
    1
  elsif ball[:x] < paddle[:x]
    -1
  else
    0
  end
end

def part2(ints)
  memory = ints.dup
  memory[0] = 2

  a = Amp.new(memory)
  i = 0

  buffer = []
  state = {}

  while (i+=1) < 200000
    event = a.step_until_event

    if event[:state] == :halted
      ap buffer
      puts "HALTED"
      break
    elsif event[:state] == :awaiting_input
      if buffer.size < 100
        state = parse_state_update(state, buffer)
      else
        state = parse_initial_state(buffer)
      end

      buffer = []

      # puts "\033[2J"
      ap "score: #{state[:score]}"
      plot_points(state[:cells])

      joystick = determine_action(state[:cells])

      a.give_input(joystick)
    elsif event[:state] == :output
      buffer.push(event[:output])
      a.ack_output
    end
  end
end

def plot_points(cells)
  graph = Array.new(24) {  Array.new(44) { 0 } }
  cells.each do |cell|
    graph[cell[:y]][cell[:x]] = cell[:tile_id]
  end
  puts graph.map { |r| r.join('')}.join("\n")
end

# part1(ints)
part2(ints)

