require 'ap'

input_lines = File.new('input/day-10.txt').readlines
rows = input_lines.map {|l| l.strip.split('')}

def parse_asteroids(rows)
  asteroids = {}

  rows.each.with_index do |row, y|
    row.each.with_index do |cell, x|
      if cell == '#'
        asteroids[[x,y]] = true
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
  # approach 1: draw 360 lines and check what is hit
  # appraoch 2: draw a line from this asteroid to every other one
  #   and see if you can reach it without any collision.
  
  # linear interpolation
  # ask: given the line between two points, does C lie on that line?
  
  asteroids.keys.count do |a_x, a_y|
    next if a_x == x && a_y == y
    other_asteroids = asteroids.keys - [[x,y], [a_x, a_y]]
    collision = other_asteroids.any? do |c_x, c_y|
      blocks_line_of_sight?([x,y], [a_x, a_y], [c_x, c_y])
    end

    !collision
  end
end

def part1(asteroids)
  counts = asteroids.keys.map.with_index do |a,n|
    puts n
    asteroids_visible_from(asteroids, a[0], a[1])
  end

  ap counts.max
end

asteroids = parse_asteroids(rows)

part1(asteroids)