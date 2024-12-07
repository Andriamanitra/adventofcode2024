input = ARGF.read.lines(chomp: true).map{|line| line.split(/\D+/).map(&:to_i)}

class Integer
  def concat(other) = self * (10 ** other.to_s.size) + other
end

part1 = input.sum {|target, *nums|
  [:*, :+].repeated_permutation(nums.size - 1).any?{|ops|
    ops = ops.each
    nums.inject{|a, b| a.send(ops.next, b)} == target
  } ? target : 0
}

part2 = input.sum {|target, *nums|
  [:*, :+, :concat].repeated_permutation(nums.size - 1).any?{|ops|
    o = ops.each
    nums.inject{|a, b| a > target ? break : a.send(o.next, b)} == target
  } ? target : 0
}

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
