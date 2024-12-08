from collections import defaultdict
from collections.abc import Callable, Generator

with open("input.txt") as f:
    lines = [line.rstrip() for line in f]

max_x = len(lines) - 1
max_y = len(lines[0]) - 1

type Pos = tuple[int, int]


def find_antinodes(
        grid: list[str],
        antinodes_from_pair: Callable[[Pos, Pos], Generator[Pos]],
) -> set[Pos]:
    seen = defaultdict[str, list[Pos]](list)
    antinodes = set[Pos]()
    for i1, line in enumerate(grid):
        for j1, ch in enumerate(line):
            if ch.isalnum():
                pos = i1, j1
                for other_pos in seen[ch]:
                    antinodes.update(antinodes_from_pair(pos, other_pos))
                seen[ch].append(pos)
    return antinodes


def generate_antinodes_part_1(a: Pos, b: Pos) -> Generator[Pos]:
    ax, ay = a
    bx, by = b
    Δx, Δy = ax - bx, ay - by
    for x, y in ((ax + Δx, ay + Δy), (bx - Δx, by - Δy)):
        if 0 <= x <= max_x and 0 <= y <= max_y:
            yield x, y


def generate_antinodes_part_2(a: Pos, b: Pos) -> Generator[Pos]:
    ax, ay = a
    bx, by = b
    Δx, Δy = ax - bx, ay - by
    while 0 <= ax <= max_x and 0 <= ay <= max_y:
        yield ax, ay
        ax, ay = ax + Δx, ay + Δy
    while 0 <= bx <= max_x and 0 <= by <= max_y:
        yield bx, by
        bx, by = bx - Δx, by - Δy


print("Part 1:", len(find_antinodes(lines, generate_antinodes_part_1)))
print("Part 2:", len(find_antinodes(lines, generate_antinodes_part_2)))
