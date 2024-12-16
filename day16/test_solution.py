# Test the Python solution with the given examples and some weird edge cases
# Intended to be run with `pytest`

from solution import parse_maze, solve


def test_example1():
    maze = (
        "###############\n"
        "#.......#....E#\n"
        "#.#.###.#.###.#\n"
        "#.....#.#...#.#\n"
        "#.###.#####.#.#\n"
        "#.#.#.......#.#\n"
        "#.#.#####.###.#\n"
        "#...........#.#\n"
        "###.#.#####.#.#\n"
        "#...#.....#.#.#\n"
        "#.#.#.###.#.#.#\n"
        "#.....#...#.#.#\n"
        "#.###.#.#.#.#.#\n"
        "#S..#.....#...#\n"
        "###############\n"
    )
    start, goal, maze = parse_maze(maze)
    part1, tiles_visited = solve(maze, start, goal)
    part2 = len(tiles_visited)
    assert part1 == 7036
    assert part2 == 45


def test_example2():
    maze = (
        "#################\n"
        "#...#...#...#..E#\n"
        "#.#.#.#.#.#.#.#.#\n"
        "#.#.#.#...#...#.#\n"
        "#.#.#.#.###.#.#.#\n"
        "#...#.#.#.....#.#\n"
        "#.#.#.#.#.#####.#\n"
        "#.#...#.#.#.....#\n"
        "#.#.#####.#.###.#\n"
        "#.#.#.......#...#\n"
        "#.#.###.#####.###\n"
        "#.#.#...#.....#.#\n"
        "#.#.#.#####.###.#\n"
        "#.#.#.........#.#\n"
        "#.#.#.#########.#\n"
        "#S#.............#\n"
        "#################\n"
    )
    start, goal, maze = parse_maze(maze)
    part1, tiles_visited = solve(maze, start, goal)
    part2 = len(tiles_visited)
    assert part1 == 11048
    assert part2 == 64


def test_small_maze():
    maze = (
        "####\n"
        "#ES#\n"
        "####\n"
    )
    start, goal, maze = parse_maze(maze)
    part1, tiles_visited = solve(maze, start, goal)
    assert part1 == 2001
    assert tiles_visited == {(1, 1), (1, 2)}


def test_two_paths():
    maze = (
        "#######\n"
        "#..S..#\n"
        "#.###.#\n"
        "#.##..#\n"
        "#..E.##\n"
        "#######\n"
    )
    start, goal, maze = parse_maze(maze)
    part1, tiles_visited = solve(maze, start, goal)
    part2 = len(tiles_visited)
    assert part1 == 4007
    assert part2 == 14
