input = ARGF.read
input = input.lines(chomp: true).map(&:bytes)

H = input.size
W = input[0].size
OBSTACLE, EMPTY, GUARD = "#.^".bytes

def find_guard(input)
  (0...H).each do |i|
    (0...W).each do |j|
      return [i,j] if input[i][j] == GUARD
    end
  end
end

def walk(input)
  def obstacle_positions(row) = row.each_index.select { |i| row[i] == OBSTACLE }
  row_obstacles = input.map { |row| obstacle_positions(row) }
  col_obstacles = input.transpose.map { |col| obstacle_positions(col) }
  i, j = find_guard(input)
  di, dj = -1, 0
  part2 = 0
  visited = Set[]
  while 0 <= i && i < H && 0 <= j && j < W
    if visited.add?((i << 16) | j)
      xr = row_obstacles[i].find_index{|x| x >= j} || row_obstacles[i].size
      row_obstacles[i].insert(xr, j)
      xc = col_obstacles[j].find_index{|x| x >= i} || col_obstacles[j].size
      col_obstacles[j].insert(xc, i)
      part2 += 1 if loop?(row_obstacles, col_obstacles, i - di, j - dj, dj, -di)
      row_obstacles[i].delete_at(xr)
      col_obstacles[j].delete_at(xc)
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

def loop?(row_o, col_o, i, j, di, dj)
  visited = Set[]
  found = nil

  loop do
    if di == 0
      found = row_o[i].bsearch_index{_1 > j} || row_o[i].size
      if dj == 1
        return false if found == row_o[i].size
        j = row_o[i][found] - 1
      else
        return false if found == 0
        j = row_o[i][found - 1] + 1
      end
    else
      found = col_o[j].bsearch_index{_1 > i} || col_o[j].size
      if di == 1
        return false if found == col_o[j].size
        i = col_o[j][found] - 1
      else
        return false if found == 0
        i = col_o[j][found - 1] + 1
      end
    end

    return true if !visited.add?((i << 18) | (j << 4) | (di+1<<2) | (dj+1))
    di, dj = dj, -di
  end
end

puts "\
Part 1: %d
Part 2: %d
" % walk(input)
