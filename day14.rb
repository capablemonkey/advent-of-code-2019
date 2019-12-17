require 'ap'

input_lines = File.new('input/day-14.txt').readlines

def parse_reaction(line)
  parts = line.split(" => ")
  output = parts[1]
  inputs = parts[0].split(", ").map {|x| x.split(" ") }.map {|qty, chem| {chemical: chem, quantity: qty.to_i}}

  {
    inputs: inputs,
    output: {
      quantity: output.split(" ")[0].to_i,
      chemical: output.split(" ")[1]
    }
  }
end

reactions = input_lines.map {|l| parse_reaction(l)}

def part1(reactions)
  queue = [[1, 'FUEL']]
  products = Hash.new {|h,k| h[k] = 0}
  ore = 0

  while queue.size > 0 do
    qty, chem = queue.shift

    if chem == 'ORE'
      ore += qty
      next
    end

    if products[chem] >= qty
      products[chem] -= qty
      next
    end

    additional_required = qty - products[chem]
    reaction = reactions.find {|r| r[:output][:chemical] == chem}

    reactions_needed = (additional_required * 1.0 / reaction[:output][:quantity]).ceil
    reaction[:inputs].each do |input|
      queue.push([input[:quantity] * reactions_needed, input[:chemical]])
    end

    quantity_created = reactions_needed * reaction[:output][:quantity]
    products[chem] += (quantity_created - qty)
  end

  puts "ore: #{ore}"
end

part1(reactions)