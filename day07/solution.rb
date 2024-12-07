input =
  ARGF
    .readlines(chomp: true)
    .map { |line| line.split(/\D+/).map(&:to_i) }

class Integer
  def concat(other) = self * (10 ** other.to_s.size) + other
end

part1, part2 = [%i'* +', %i'* + concat'].map do |operators|
  input.sum do |target, initial, *nums|
    operators.repeated_permutation(nums.size).any? do |permutation|
      ops = permutation.each
      target == nums.inject(initial) do |acc, n|
        break if acc > target
        acc.send(ops.next, n)
      end
    end ? target : 0
  end
end

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
