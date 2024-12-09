ARGV << "input.txt"
s = ARGF.read.chomp

total_length = s.chars.sum(&:to_i)
spaces = [nil] * total_length
id = 0
i = 0
is_space = false
s.each_char do |c|
  length = c.to_i
  if is_space
    i += length
  else
    length.times do
      spaces[i] = id
      i += 1
    end
    id += 1
  end
  is_space = !is_space
end

left = 0
right = i
while left < right
  while left < right && !spaces[left].nil?
    left += 1
  end
  while left < right && spaces[right].nil?
    right -= 1
  end
  if left < right
    spaces[left], spaces[right] = spaces[right], spaces[left]
  end
end

p spaces.compact.each_with_index.sum{_1 * _2}

filled = []
empty = Hash.new{|h,k| h[k] = []}
id = 0
i = 0
s.each_char.zip([false, true].cycle) do |c, is_space|
  if c.to_i > 0
    if is_space
      empty[c.to_i].push(i)
    else
      filled.push([i, c.to_i, id])
      id += 1
    end
    i += c.to_i
  end
end

moved = []
filled.reverse_each do |i, length, id|
  best_i = nil
  best_length = nil
  (length..9).each do |len|
    found = empty.dig(len, 0)
    if !found.nil? && (best_i.nil? || best_i > found)
      if found < i
        best_i = found
        best_length = len
      end
    end
  end
  if best_i.nil?
    moved.push([i, length, id])
  else
    moved.push([best_i, length, id])
    empty[best_length].shift
    rem = best_length - length
    if rem > 0
      empty[rem].push(best_i + length)
      empty[rem].sort!
    end
  end
end

spaces = [nil] * total_length
moved.each do |i, length, id|
  (i...i+length).each do |idx|
    spaces[idx] = id
  end
end
p spaces.each_with_index.sum{|val, i| val.to_i * i }
