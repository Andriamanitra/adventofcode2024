from collections import defaultdict
from collections.abc import Callable, Generator

with open("input.txt") as f:
    lines = [line.rstrip() for line in f]

MAX_X = len(lines) - 1
MAX_Y = len(lines[0]) - 1

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


def inbounds(pos: Pos) -> bool:
    x, y = pos
    return 0 <= x <= MAX_X and 0 <= y <= MAX_Y


def generate_antinodes_part_1(a: Pos, b: Pos) -> Generator[Pos]:
    ax, ay = a
    bx, by = b
    Δx, Δy = ax - bx, ay - by
    for pos in ((ax + Δx, ay + Δy), (bx - Δx, by - Δy)):
        if inbounds(pos):
            yield pos


def generate_antinodes_part_2(a: Pos, b: Pos) -> Generator[Pos]:
    ax, ay = a
    bx, by = b
    Δx, Δy = ax - bx, ay - by
    while inbounds((ax, ay)):
        yield ax, ay
        ax, ay = ax + Δx, ay + Δy
    while inbounds((bx, by)):
        yield bx, by
        bx, by = bx - Δx, by - Δy


print("Part 1:", len(find_antinodes(lines, generate_antinodes_part_1)))
print("Part 2:", len(find_antinodes(lines, generate_antinodes_part_2)))
