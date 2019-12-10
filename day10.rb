require 'ap'

input_lines = File.new('input/day-10.txt').readlines
rows = input_lines.map {|l| l.strip.split('')}

def parse_asteroids(rows)
  asteroids = []

  rows.each.with_index do |row, y|
    row.each.with_index do |cell, x|
      if cell == '#'
        asteroids.push([x,y])
      end
    end
  end

  asteroids
end

def distance_between_line_and_point(x1, y1, x2, y2, x3, y3)
  px = x2 - x1
  py = y2 - y1

  norm = px * px + py * py
  u = ((x3 - x1) * px + (y3 - y1) * py) / norm.to_f

  if u > 1
    u = 1
  elsif u < 0
    u = 0
  end

  x = x1 + u * px
  y = y1 + u * py
  dx = x - x3
  dy = y - y3
  dist = (dx * dx + dy * dy) ** 0.5
  dist
end

# Does c block the line of sight between a and b?
def blocks_line_of_sight?(a, b, c)
  hit = distance_between_line_and_point(a[0], a[1], b[0], b[1], c[0], c[1]) < 0.01
  # ap "#{c} blocks #{a} -> #{b}" if hit
  hit
end

def asteroids_visible_from(asteroids, x, y)
  # appraoch 2: draw a line from this asteroid to every other one
  #   and see if you can reach it without any collision.
  asteroids.select do |a_x, a_y|
    next if a_x == x && a_y == y
    other_asteroids = asteroids - [[x,y], [a_x, a_y]]
    collision = other_asteroids.any? do |c_x, c_y|
      blocks_line_of_sight?([x,y], [a_x, a_y], [c_x, c_y])
    end

    !collision
  end
end

def part1(asteroids)
  counts = asteroids.map.with_index do |a,n|
    puts n
    [a, asteroids_visible_from(asteroids, a[0], a[1]).count]
  end

  ap counts.max_by {|asteroid, visible_count| visible_count }
end

def angle(x1, y1, x2, y2)
  radians = Math.atan2(y2 - y1, x2 - x1)
  deg = radians * (180 / Math::PI)

  if deg < -90
    deg = deg + 360.0
  end

  deg
end

def clockwise_hits(asteroids, cannon_x, cannon_y)
  visible_asteroids = asteroids_visible_from(asteroids, cannon_x, cannon_y)

  hits = visible_asteroids.
    map {|x,y| [angle(cannon_x, cannon_y, x, y),[x,y]]}. # round to nearest degree?
    sort_by {|angle, asteroid| angle }

  hits
end

def part2(asteroids, cannon_x, cannon_y)
  # given the cannon x,y
  # get all visible asteroids from x,y
  # calculate angle between visible asteroid and cannon
  # sort visible asteroids by angle
  asteroids_remaining = asteroids.dup - [[cannon_x, cannon_y]]
  destroyed = []

  while asteroids_remaining.size > 0
    hits = clockwise_hits(asteroids_remaining, cannon_x, cannon_y).map {|angle, asteroid| asteroid}
    asteroids_remaining = asteroids_remaining - hits
    destroyed += hits

    ap "removed #{hits.count} asteroids, #{asteroids_remaining.size} remaining"
  end

  ap destroyed[199]
end

asteroids = parse_asteroids(rows)

part1(asteroids)
part2(asteroids, 23, 20)
