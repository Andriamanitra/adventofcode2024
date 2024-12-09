s = ARGF.readline.chomp

total_length = s.each_char.sum(&:to_i)
spaces = [nil] * total_length

pos = 0
s.each_char.zip([false, true].cycle, 0..) do |c, is_space, idx|
  length = c.to_i
  if is_space
    pos += length
  else
    id = idx / 2
    length.times do
      spaces[pos] = id
      pos += 1
    end
  end
end

left = 0
right = pos
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

p spaces.each_with_index.sum { |val, idx| val.to_i * idx }

filled = []
empty_spots = Array.new(10) { [] }

i = 0
s.each_char.zip([false, true].cycle, 0..) do |c, is_space, idx|
  length = c.to_i
  next if length.zero?
  if is_space
    empty_spots[length].push(i)
  else
    id = idx / 2
    filled.push([i, length, id])
  end
  i += length
end

moved = filled.reverse_each.map do |i, length, id|
  best_i = i
  best_length = nil
  (length..9).each do |len|
    next if empty_spots[len].empty?
    if empty_spots[len][0] < best_i
      best_i = empty_spots[len][0]
      best_length = len
    end
  end
  if best_i < i
    empty_spots[best_length].shift
    rem = best_length - length
    if rem > 0
      new_empty_idx_spots = best_i + length
      e = empty_spots[rem].bsearch_index { |i| i >= new_empty_idx_spots }
      empty_spots[rem].insert(e, new_empty_idx_spots)
    end
  end
  [best_i, length, id]
end

p moved.sum { |i, length, id| id * (i...i+length).sum }
