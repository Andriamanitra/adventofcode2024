from __future__ import annotations

from heapq import heappop, heappush

type Pos = tuple[int, int]
type Maze = dict[Pos, object]
Empty, Wall = object(), object()
North, East, South, West = 101, 102, 103, 104

RIGHT = {
    North: East,
    East: South,
    South: West,
    West: North
}
LEFT = {v: k for k, v in RIGHT.items()}


def read_maze(filename: str) -> tuple[Pos, Pos, Maze]:
    with open("input.txt") as f:
        input_str = f.read()

    start, goal = None, None
    maze = {}
    for i, line in enumerate(input_str.split()):
        for j, ch in enumerate(line):
            if ch == "S":
                start = (i, j)
            if ch == "E":
                goal = (i, j)

            if ch == "#":
                maze[i, j] = Wall
            else:
                maze[i, j] = Empty
    assert start is not None
    assert goal is not None
    return start, goal, maze


def step(pos: Pos, facing: int) -> Pos:
    i, j = pos
    if facing == North:
        return i - 1, j
    if facing == South:
        return i + 1, j
    if facing == West:
        return i, j - 1
    if facing == East:
        return i, j + 1
    e = "facing should be one of North, South, West, East"
    raise ValueError(e)


def print_maze_and_path(maze: Maze, path: set[Pos]) -> None:
    height, width = max(maze)
    for i in range(height + 1):
        row = "".join(("O" if (i, j) in path else ".#"[maze[i, j] is Wall]) for j in range(width + 1))
        print(row)


def solve(maze: Maze, start: Pos, goal: Pos) -> None:
    lowest_score = float("inf")
    visited = {}
    arrived_from = {}
    q = [(0, start, East), (2000, start, West)]
    while q:
        score, pos, facing = heappop(q)
        if score > lowest_score:
            return

        if pos == goal:
            lowest_score = score
            path = [(pos, facing)]
            for pos, facing in path:
                if pos != start:
                    path.extend(arrived_from[pos, facing])
            tiles_visited = {pos for pos, _ in path}
            # print_maze_and_path(maze, tiles_visited)
            print(f"(Part 1) Arrived at goal with {score=}")
            print(f"(Part 2) Visited {len(tiles_visited)} tiles along the best paths")
        else:
            options = (
                (facing, 1),
                (LEFT[facing], 1001),
                (RIGHT[facing], 1001),
            )
            for nextfacing, cost in options:
                nextpos = step(pos, nextfacing)
                if maze[nextpos] is Empty:
                    previous_cost = visited.get((nextpos, nextfacing))
                    nextcost = score + cost
                    if previous_cost is None or previous_cost > nextcost:
                        arrived_from[nextpos, nextfacing] = [(pos, facing)]
                        visited[nextpos, nextfacing] = nextcost
                        heappush(q, (nextcost, nextpos, nextfacing))
                    elif previous_cost == nextcost:
                        arrived_from[nextpos, nextfacing].append((pos, facing))


if __name__ == "__main__":
    start, goal, maze = read_maze("input.txt")
    solve(maze, start, goal)
