$rules, $updates = ARGF.read.split("\n\n").map { |s| s.lines.map{ _1.scan(/\d+/).map(&:to_i) } }

def deps(pages)
  dependencies = pages.to_h { [_1, Set[]] }
  dependees    = pages.to_h { [_1, Set[]] }
  $rules.each do |a, b|
    if pages.include?(a) && pages.include?(b)
      dependencies[b] << a
      dependees[a]    << b
    end
  end
  {dependencies:, dependees:}
end

def toposort(pages)
  deps(pages) => {dependencies:, dependees:}
  sorted = dependencies.keys.select { |k| dependencies[k].empty? }
  (0..).each do |i|
    return sorted if i >= sorted.size
    dependees[sorted[i]].each do |d|
      sorted.push(d) if dependencies[d].delete(sorted[i]).empty?
    end
  end
end

$results = {part1: 0, part2: 0}
$updates.each do |pages|
  ordered = toposort(pages) & pages
  $results[ordered == pages ? :part1 : :part2] += ordered[ordered.size / 2]
end
puts $results
