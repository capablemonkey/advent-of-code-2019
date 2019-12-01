input_lines = File.new('input/day-01.txt').readlines
modules = input_lines.map(&:to_i)

def fuel(mass)
  (mass / 3.0).floor - 2
end

def total_fuel(modules)
  modules.map { |m| fuel(m) }.sum
end

def real_fuel(mass)
  f = fuel(mass)
  return 0 if f <= 0

  f + real_fuel(f)
end

def part1(modules)
  puts(total_fuel(modules))
end

def part2(modules)
  puts(modules.map {|f| real_fuel(f)}.sum)
end

part1(modules)
part2(modules)