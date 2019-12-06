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

def dfs(map, root, target, path)
  obj = map[root]
  return path if obj[:children].include?(target)

  candidates = obj[:children] + [obj[:parent]] - path
  candidates.each do |c|
    result = dfs(map, c, target, path + [c])
    return result if result
  end

  false
end

def part1(map)
  puts count_orbits(map, "COM", 0)
end

def part2(map)
  ap dfs(map, "YOU", "SAN", []).size - 1
end

map = parse_orbits(orbits)
part1(map)
part2(map)