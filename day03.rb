require 'ap'

input_lines = File.new('input/day-03.txt').readlines
lines = input_lines.map {|l| l.split(',')}

def parse_segment(segment)
  return {
    direction: segment[0],
    value: segment[1..-1].to_i
  }
end

def line_to_points(segments)
  x = 0
  y = 0
  points = []

  segments.each do |segment|
    s = parse_segment(segment)

    if s[:direction] == 'U'
      points = points.concat((1..s[:value]).map {|n| [x, y + n] }.to_a)
    elsif s[:direction] == 'D'
      points = points.concat((1..s[:value]).map {|n| [x, y - n] }.to_a)
    elsif s[:direction] == 'L'
      points = points.concat((1..s[:value]).map {|n| [x - n, y] }.to_a)
    elsif s[:direction] == 'R'
      points = points.concat((1..s[:value]).map {|n| [x + n, y] }.to_a)
    end

    x = points.last[0]
    y = points.last[1]
  end

  points
end

def traverse(points)
  steps_memo = {}

  steps = 0
  points.map do |x, y|
    steps += 1
    [x,y, steps_memo[[x,y]] ||= steps]
  end
end

def combined_steps(intersection, steps_a, steps_b)
  a = steps_a.find {|x,y,z| x == intersection[0] && y == intersection[1]}[2]
  b = steps_b.find {|x,y,z| x == intersection[0] && y == intersection[1]}[2]

  a + b
end

def part1(lines)
  # points_a = line_to_points(["R75",'D30','R83','U83','L12','D49','R71','U7','L72'])
  # points_b = line_to_points(["U62","R66","U55","R34","D71","R55","D58",'R83'])
  points_a = line_to_points(lines[0])
  points_b = line_to_points(lines[1])

  intersections = points_a & points_b

  distances = intersections.map {|x, y| x.abs + y.abs }.sort
  ap distances
end

def part2(lines)
  # points_a = line_to_points(["R75",'D30','R83','U83','L12','D49','R71','U7','L72'])
  # points_b = line_to_points(["U62","R66","U55","R34","D71","R55","D58",'R83'])
  # points_a = line_to_points(['R98','U47','R26','D63','R33','U87','L62','D20','R33','U53','R51'])
  # points_b = line_to_points(['U98','R91','D20','R16','D67','R40','U7','R15','U6','R7'])
  # points_a = line_to_points('R8,U5,L5,D3'.split(','))
  # points_b = line_to_points('U7,R6,D4,L4'.split(','))
  points_a = line_to_points(lines[0])
  points_b = line_to_points(lines[1])

  intersections = points_a & points_b

  steps_a = traverse(points_a)
  steps_b = traverse(points_b)

  distances = intersections.map {|int| combined_steps(int, steps_a, steps_b) }.sort
  ap distances
end

part1(lines)
part2(lines)