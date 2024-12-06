input = ARGF.read
input = input.lines(chomp: true).map(&:bytes)

H = input.size
W = input[0].size
GUARD = '^'.ord
OBSTACLE = '#'.ord
EMPTY = '.'.ord

def find_guard(input)
  (0...H).each do |i|
    (0...W).each do |j|
      return [i,j] if input[i][j] == GUARD
    end
  end
end

def walk(input)
  i, j = find_guard(input)
  di, dj = -1, 0
  part2 = 0
  visited = Set[]
  while 0 <= i && i < H && 0 <= j && j < W
    if visited.add?((i << 16) | j)
      input[i][j] = OBSTACLE
      part2 += 1 if loop?(input, i - di, j - dj, di, dj)
      input[i][j] = EMPTY
    end

    i += di
    j += dj
    break if i < 0 || j < 0 || i >= H || j >= W
    if input[i][j] == OBSTACLE
      i -= di
      j -= dj
      di, dj = dj, -di
    end
  end
  [visited.size, part2]
end

def loop?(input, i, j, di, dj)
  visited = Set[]
  while 0 <= i && i < H && 0 <= j && j < W
    return true if !visited.add?((i << 18) | (j << 4) | (di+1<<2) | (dj+1))
    i += di
    j += dj
    return false if i < 0 || j < 0 || i >= H || j >= W
    if input[i][j] == OBSTACLE
      i -= di
      j -= dj
      di, dj = dj, -di
    end
  end
  false
end

puts "\
Part 1: %d
Part 2: %d
" % walk(input)
