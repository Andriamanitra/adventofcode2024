# nice and concise solution inspired by this comment on reddit:
# https://www.reddit.com/r/adventofcode/comments/1hcdnk0/2024_day_12_solutions/m1nj6se/

type Pos = complex
type Direction = complex
type Region = frozenset[Pos]
type Edge = tuple[Pos, Direction]

DIRECTIONS = (1, -1, 1j, -1j)

def neighbors_of(p: Pos) -> list[Pos]:
    return [p + d for d in DIRECTIONS]

def regions_of(grid: dict[Pos, str]) -> set[Region]:
    regions = {pos: {pos} for pos in grid}
    for pos, this in grid.items():
        for npos in neighbors_of(pos):
            if grid.get(npos) == this:
                regions[pos] |= regions[npos]
                for p in regions[npos]:
                    regions[p] = regions[pos]
    return {frozenset(region) for region in regions.values()}

def edges_of(region: Region) -> set[Edge]:
    return {(p, d) for p in region for d in DIRECTIONS if (p + d) not in region}

def sides_of(region: Region) -> set[Edge]:
    edges = edges_of(region)
    return {(pos, d) for pos, d in edges if (pos + d * 1j, d) not in edges}

with open("input.txt") as f:
    lines = f.read().split()

grid = {
    x + y * 1j: ch
    for y, row in enumerate(lines)
    for x, ch in enumerate(row)
}
regions = regions_of(grid)

part1 = sum(len(region) * len(edges_of(region)) for region in regions)
print("Part 1:", part1)

part2 = sum(len(region) * len(sides_of(region)) for region in regions)
print("Part 2:", part2)
