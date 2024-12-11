from collections import Counter


def blink(counts: Counter[int]) -> None:
    old_counts = list(counts.items())
    counts.clear()
    for stone, count in old_counts:
        if stone == 0:
            counts[1] += count
        elif len(str(stone)) & 1 == 0:
            s = str(stone)
            half = len(s) // 2
            counts[int(s[:half])] += count
            counts[int(s[half:])] += count
        else:
            counts[stone * 2024] += count

def read_input() -> str:
    import sys, os
    if not os.isatty(sys.stdin.fileno()):
        return sys.stdin.read()
    with open(sys.argv[1] if len(sys.argv) > 1 else "input.txt") as f:
        return f.read()


def solve(nums: list[int]) -> None:
    stone_counter = Counter(nums)
    for _ in range(25): blink(stone_counter)
    print("Part 1:", sum(stone_counter.values()))
    for _ in range(50): blink(stone_counter)
    print("Part 2:", sum(stone_counter.values()))


if __name__ == "__main__":
    solve([int(s) for s in read_input().split()])
