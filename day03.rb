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
      points = points.concat((0..s[:value]).map {|n| [x, y + n] }.to_a)
    elsif s[:direction] == 'D'
      points = points.concat((0..s[:value]).map {|n| [x, y - n] }.to_a)
    elsif s[:direction] == 'L'
      points = points.concat((0..s[:value]).map {|n| [x - n, y] }.to_a)
    elsif s[:direction] == 'R'
      points = points.concat((0..s[:value]).map {|n| [x + n, y] }.to_a)
    end

    x = points.last[0]
    y = points.last[1]
  end

  points
end

def part1(lines)
  # puts line_to_points(lines)
  # points_a = line_to_points(["R75",'D30','R83','U83','L12','D49','R71','U7','L72'])
  # points_b = line_to_points(["U62","R66","U55","R34","D71","R55","D58",'R83'])
  points_a = line_to_points(lines[0])
  points_b = line_to_points(lines[1])

  intersections = points_a & points_b

  distances = intersections.map {|x, y| x.abs + y.abs }.sort
  ap distances
end

part1(lines)
