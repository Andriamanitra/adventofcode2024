from collections import defaultdict

with open("input.txt") as f:
    patterns, designs = f.read().split("\n\n")
patterns = patterns.split(", ")
designs = designs.split()

patterns_by_letter = defaultdict(list)
for pattern in patterns:
    patterns_by_letter[pattern[0]].append(pattern)

part1 = 0
part2 = 0
for design in designs:
    memo = [1] + [0] * len(design)
    for i, first_letter in enumerate(design):
        for pattern in patterns_by_letter[first_letter]:
            if design.startswith(pattern, i):
                memo[i + len(pattern)] += memo[i]
    part1 += memo[-1] > 0
    part2 += memo[-1]

print("Part 1:", part1)
print("Part 2:", part2)
