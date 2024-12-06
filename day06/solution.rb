ARGV << 'input.txt'
input = ARGF.read
input = input.lines(chomp: true).map(&:chars)

$h = input.size
$w = input[0].size
coords = [*0...$h].product([*0...$w])
$gi, $gj = coords.find{|i,j|input[i][j] == ?^}

$dirs = [[-1, 0], [0, 1], [1, 0], [0, -1]]

def walk(input)
  part2 = 0
  i, j = $gi, $gj
  d = 0
  visited = Set[]
  while 0 <= i && i < $h && 0 <= j && j < $w
    if visited.add?([i, j])
      input[i][j] = '#'
      part2 += 1 if loop?(input, i - $dirs[d][0], j - $dirs[d][1], (d+1)%4)
      input[i][j] = '.'
    end

    ni = i + $dirs[d][0]
    nj = j + $dirs[d][1]
    if ni >= 0 && nj >= 0 && input.dig(ni, nj) == '#'
      d += 1
      d = 0 if d == 4
    else
      i = ni
      j = nj
    end
  end
  [visited.size, part2]
end

def loop?(input, i, j, d)
  visited = Set[]
  while 0 <= i && i < $h && 0 <= j && j < $w
    return true if !visited.add?([i, j, d])
    ni = i + $dirs[d][0]
    nj = j + $dirs[d][1]
    if ni >= 0 && nj >= 0 && input.dig(ni, nj) == '#'
      d += 1
      d = 0 if d == 4
    else
      i = ni
      j = nj
    end
  end
  false
end

puts "\
Part 1: %d
Part 2: %d
" % walk(input)
