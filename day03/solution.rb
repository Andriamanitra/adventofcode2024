input = ARGF.read

# Part 1:
p input.scan(/mul\((\d+),(\d+)\)/).sum{_1.to_i * _2.to_i}

# Part 2:
tokens = input.scan(/mul\((\d+),(\d+)\)|(do|don\'t)\(\)/)
_enabled, total = tokens.reduce([true, 0]) { |(enabled, acc), (a, b, toggle)|
  case toggle
  when "do" then [true, acc]
  when "don't" then [false, acc]
  else
    acc += a.to_i * b.to_i if enabled
    [enabled, acc]
  end
}
p total
