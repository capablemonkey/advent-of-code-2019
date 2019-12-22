require 'ap'
require "deep_clone"

input_lines = File.new('input/day-15.txt').readlines
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
  attr_accessor :state, :memory, :pos, :last_output, :base_address, :input_dest

  def initialize(ints=[1])
    # right pad memory with 0s up to 10,000:
    @memory = ints.dup.concat(Array.new(1_000_000 - ints.size, 0))
    @pos = 0
    @state = :running
    @last_output = nil
    @base_address = 0
    @input_dest = 0
  end

  def step
    raise "still awaiting input" if @state == :awaiting_input
    raise "halted" if @state == :halted

    instr = parse_instruction(@memory[@pos])

    # ap "intcode: #{@memory[@pos]}, pos #{@pos}, #{memory[(@pos - 2)..(@pos + 2)]}"
    # ap instr

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
    raise "not in awaiting_input state" unless @state == :awaiting_input
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

  def duplicate
    a = Amp.new
    a.memory = @memory.clone
    a.state = @state.clone
    a.pos = @pos.clone
    a.last_output = @last_output.clone
    a.base_address = @base_address.clone
    a.input_dest = @input_dest.clone

    a
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

def dfs(computer, direction, history=[])
  new_computer = computer.duplicate
  event = new_computer.step_until_event
  new_computer.give_input(direction)
  event = new_computer.step_until_event
  new_computer.ack_output

  result = event[:output]

  ap "went #{direction} and got #{result} history: #{history}"

  return false if result == 0
  return history + [direction] if result == 2

  backtrack = {
    1 => 2,
    2 => 1,
    3 => 4,
    4 => 3
  }

  [1,2,3,4].each do |d|
    next if d == backtrack[direction]
    r = dfs(new_computer, d, history + [direction])
    if r
      ap "got result"
      return r
    end
  end

  nil
end

def part1(ints)
  a = Amp.new(ints)
  a.step_until_event

  results = [1,2,4,3].map do |i|
    dfs(a, i)
  end

  ap results
end

def bfs(computer)
  # beginning is 0,0
  grid = {}
  queue = [{computer: computer.duplicate, x: 0, y: 0}]

  while !queue.empty?
    cell = queue.shift
    event = cell[:computer].step_until_event

    directions = {
      1 => {x: 0, y: 1},
      2 => {x: 0, y: -1},
      3 => {x: -1, y: 0},
      4 => {x: 1, y: 0},
    }

    [1,2,3,4].each do |d|
      dest = [cell[:x] + directions[d][:x], cell[:y] + directions[d][:y]]
      next if grid[dest]

      # puts "visiting #{dest}"

      c = cell[:computer].duplicate
      c.give_input(d)
      event = c.step_until_event
      c.ack_output

      result = event[:output]
      grid[dest] = result

      next if result == 0

      queue.push({computer: c.duplicate, x: dest[0], y: dest[1]})
    end
  end

  grid
end

def print_grid(grid)
  graph = Array.new(50) {  Array.new(70) { " " } }
  value_map = {1 => ' ', 0 => '#', 2 => 'O'}
  grid.each do |coor, value|
    graph[coor[1] + 25][coor[0] + 25] = value_map[value]
  end
  puts graph.map { |r| r.join('')}.join("\n")
end

def spread_oxygen(grid)
  g = grid.dup

  oxygens = g.select {|k,v| v == 2}

  directions = {
    1 => {x: 0, y: 1},
    2 => {x: 0, y: -1},
    3 => {x: -1, y: 0},
    4 => {x: 1, y: 0},
  }

  oxygens.each do |coor, _|
    directions.values.each do |d|
      neighbor = [coor[0] + d[:x], coor[1] + d[:y]]
      g[neighbor] = 2 if g[neighbor] == 1
    end
  end

  g
end

def part2(ints)
  # discover map with BFS
  a = Amp.new(ints)
  grid = bfs(a)
  ap grid
  print_grid(grid)

  # given map and oxygen pocket, fill map with oxygen
  counter = 0
  until grid.all? {|k,v| v == 2 || v == 0} do
    grid = spread_oxygen(grid)
    counter += 1
    puts counter
  end
end

# part1(ints)
part2(ints)
