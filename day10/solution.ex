defmodule Day10 do
  def read_input(fname) do
    File.read!(fname)
    |> String.split()
    |> Enum.map(fn s -> Enum.map(String.graphemes(s), &String.to_integer(&1)) end)
  end

  def find_trailhead_ends(grid, h, i, j) do
    cond do
      i < 0 or j < 0 or i >= length(grid) or j >= length(List.first(grid)) -> []
      get_in(grid, [Access.at(i), Access.at(j)]) == h ->
        if h == 9 do
          [{i, j}]
        else
          Enum.concat([
            find_trailhead_ends(grid, h+1, i+1, j),
            find_trailhead_ends(grid, h+1, i-1, j),
            find_trailhead_ends(grid, h+1, i, j+1),
            find_trailhead_ends(grid, h+1, i, j-1),
          ])
        end
      true -> []
    end
  end

  def solve(grid, count_fn) do
    height = length(grid)
    width = length(List.first(grid))

    for i <- 0..height do
      for j <- 0..width do
        find_trailhead_ends(grid, 0, i, j)
      end
    end
    |> Enum.concat()
    |> Enum.map(count_fn)
    |> Enum.sum()
  end
end

grid = Day10.read_input("input.txt")
part1 = Day10.solve(grid, fn x -> length(Enum.uniq(x)) end)
IO.puts("Part 1: #{part1}")
part2 = Day10.solve(grid, fn x -> length(x) end)
IO.puts("Part 2: #{part2}")
