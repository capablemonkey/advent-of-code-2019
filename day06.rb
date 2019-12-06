require 'ap'

input_lines = File.new('input/day-06.txt').readlines
orbits = input_lines.map {|l| l.strip.split(')')}

def parse_orbits(orbits)
  map = Hash.new {|h, k| h[k] = {children: [], parent: nil}}

  orbits.each do |parent, child|
    map[parent][:children].push(child)
    map[child][:parent] = parent
  end

  map
end

def count_orbits(map, root, depth)
  obj = map[root]
  return depth if obj[:children].empty?

  depth + obj[:children].map {|c| count_orbits(map, c, depth + 1)}.sum
end

def part1(orbits)
  map = parse_orbits(orbits)
  puts count_orbits(map, "COM", 0)
end

part1(orbits)