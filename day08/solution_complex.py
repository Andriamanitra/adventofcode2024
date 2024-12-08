from collections import defaultdict
from collections.abc import Callable, Generator

with open("input.txt") as f:
    lines = [line.rstrip() for line in f]

MAX_X = len(lines) - 1
MAX_Y = len(lines[0]) - 1

type Pos = complex


def find_antinodes(
        grid: list[str],
        antinodes_from_pair: Callable[[Pos, Pos], Generator[Pos]],
) -> set[Pos]:
    seen = defaultdict[str, list[Pos]](list)
    antinodes = set[Pos]()
    for x, line in enumerate(grid):
        for y, ch in enumerate(line):
            if ch.isalnum():
                pos = x * 1j + y
                for other_pos in seen[ch]:
                    antinodes.update(antinodes_from_pair(pos, other_pos))
                seen[ch].append(pos)
    return antinodes


def inbounds(pos: Pos) -> bool:
    return 0 <= int(pos.imag) <= MAX_X and 0 <= int(pos.real) <= MAX_Y


def generate_antinodes_part_1(a: Pos, b: Pos) -> Generator[Pos]:
    delta = a - b
    if inbounds(a + delta):
        yield a + delta
    if inbounds(b - delta):
        yield b - delta


def generate_antinodes_part_2(a: Pos, b: Pos) -> Generator[Pos]:
    delta = a - b
    while inbounds(a):
        yield a
        a += delta
    while inbounds(b):
        yield b
        b -= delta


print("Part 1:", len(find_antinodes(lines, generate_antinodes_part_1)))
print("Part 2:", len(find_antinodes(lines, generate_antinodes_part_2)))
