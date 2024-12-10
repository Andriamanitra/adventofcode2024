with open("input.txt") as f:
    grid = {
        (r, c): ch
        for r, row in enumerate(f.readlines())
        for c, ch in enumerate(row)
    }

coords = list(grid.keys())

part1 = 0
XMAS = [(letter, (i, i)) for i, letter in enumerate("XMAS")]
for r, c in coords:
    for Δr in (-1, 0, 1):
        for Δc in (-1, 0, 1):
            if Δr == 0 and Δc == 0: continue
            part1 += all(grid.get((r + Δr * i, c + Δc * j)) == ch for ch, (i, j) in XMAS)

part2 = 0
for r, c in coords:
    g = grid.get
    diagonal1 = {g((r+1, c+1)), g((r-1, c-1))}
    diagonal2 = {g((r+1, c-1)), g((r-1, c+1))}
    part2 += g((r, c)) == "A" and set("MS") == diagonal1 == diagonal2

print("Part 1:", part1)
print("Part 2:", part2)
