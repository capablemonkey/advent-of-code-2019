require 'ap'

input_lines = File.new('input/day-12.txt').readlines


def parse_moon(string)
  regex = /<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/
  matches = regex.match(string).captures
  {
    :x => matches[0].to_i,
    :y => matches[1].to_i,
    :z => matches[2].to_i,
    :vx => 0,
    :vy => 0,
    :vz => 0
  }
end

def gravity(moons)
  moons.map do |m|
    delta_x = 0
    delta_y = 0
    delta_z = 0

    moons.each do |other_moon|
      if m[:x] > other_moon[:x]
        delta_x -= 1
      elsif m[:x] < other_moon[:x]
        delta_x += 1
      end

      if m[:y] > other_moon[:y]
        delta_y -= 1
      elsif m[:y] < other_moon[:y]
        delta_y += 1
      end

      if m[:z] > other_moon[:z]
        delta_z -= 1
      elsif m[:z] < other_moon[:z]
        delta_z += 1
      end
    end

    m.merge({
      vx: m[:vx] += delta_x,
      vy: m[:vy] += delta_y,
      vz: m[:vz] += delta_z,
    })
  end
end

def move(moons)
  moons.map do |m|
    m.merge({
      x: m[:x] += m[:vx],
      y: m[:y] += m[:vy],
      z: m[:z] += m[:vz],
    })
  end
end

def total_energy(moon)
  potential = moon[:x].abs + moon[:y].abs + moon[:z].abs
  kinetic = moon[:vx].abs + moon[:vy].abs + moon[:vz].abs
  potential * kinetic
end

def part1(moons)
  m = moons.dup

  (0...1000).each do |i|
    puts i
    m = gravity(moons)
    m = move(moons)
  end

  puts m.map {|m| total_energy(m)}.sum
end

def key(m)
  [m[:x], m[:y], m[:z], m[:vx], m[:vy], m[:vz]]
end

def state_key(moons)
  moons.map {|m| key(m)}
end

def part2(moons)
  m = moons.dup

  states = {}
  states[key(m[0])] ||= {}
  states[key(m[0])][key(m[1])] ||= {}
  states[key(m[0])][key(m[1])][key(m[2])] ||= {}
  states[key(m[0])][key(m[1])][key(m[2])][key(m[3])] = true

  (0...1000000).each do |i|
    puts i if i % 10_000 == 0
    m = gravity(moons)
    m = move(moons)

    k1 = key(m[0])
    k2 = key(m[1])
    k3 = key(m[2])
    k4 = key(m[3])

    if states.key?(k1)
      puts "hehe"
      if states[k1].key?(k2)
        if states[k1][k2].key?(k3)
          if states[k1][k2][k3][k4] == true
            ap "found it!"
            ap i
            return
          end
        end
      end
    end

    states[k1] ||= {}
    states[k1][k2] ||= {}
    states[k1][k2][k3] ||= {}
    states[k1][k2][k3][k4] = true
  end

  ap states
end

moons = input_lines.map{|l| parse_moon(l)}

ap moons
# ap gravity(moons)
# ap move(moons)
part2(moons)
