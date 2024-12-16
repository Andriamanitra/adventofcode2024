from heapq import heappush, heappop

Empty, Wall = object(), object()
North, East, South, West = 101, 102, 103, 104

RIGHT = {
    North: East,
    East: South,
    South: West,
    West: North
}
LEFT = {v: k for k, v in RIGHT.items()}

with open("input.txt") as f:
    input_str = f.read()

maze = {}
for i, line in enumerate(input_str.split()):
    for j, ch in enumerate(line):
        if ch == "S":
            start = (i, j)
        if ch == "E":
            goal = (i, j)

        if ch == "#":
            maze[i,j] = Wall
        else:
            maze[i,j] = Empty

def step(pos, facing):
    i, j = pos
    if facing == North:
        return i-1, j
    if facing == South:
        return i+1, j
    if facing == West:
        return i, j-1
    if facing == East:
        return i, j+1
    raise ValueError("invalid facing")

def print_maze_and_path(maze, path):
    height, width = max(maze)
    for i in range(height+1):
        row = "".join(("O" if (i,j) in path else ".#"[maze[i,j] is Wall]) for j in range(width+1))
        print(row)

q = [(0, start, East)]
BEST_SCORE = 8_765_432_100
visited = {}
arrived_from = {}
while q:
    score, pos, facing = heappop(q)
    if score > BEST_SCORE:
        break

    if pos == goal:
        BEST_SCORE = score

        i = 0
        path = [(pos, facing)]
        for pos, facing in path:
            if pos != start:
                path.extend(arrived_from[pos, facing])
        tiles_visited = set(pos for pos, _ in path)
        n_tiles = len(set(tiles_visited))
        # print_maze_and_path(maze, squares_along_best_paths)
        print(f"(Part 1) Arrived at goal with {score=}")
        print(f"(Part 2) Visited {n_tiles} tiles along the best paths")
    else:
        OPTIONS = (
            (facing, 1),
            (LEFT[facing], 1001),
            (RIGHT[facing], 1001),
            (LEFT[LEFT[facing]], 2001),
        )
        for nextfacing, cost in OPTIONS:
            nextpos = step(pos, nextfacing)
            if maze[nextpos] is Empty:
                nextcost = visited.get((nextpos, nextfacing))
                if nextcost is None or nextcost > score + cost:
                    arrived_from[nextpos, nextfacing] = [(pos, facing)]
                    visited[nextpos, nextfacing] = score+cost
                    heappush(q, (score+cost, nextpos, nextfacing))
                elif nextcost == score + cost:
                    arrived_from[nextpos, nextfacing].append((pos, facing))
