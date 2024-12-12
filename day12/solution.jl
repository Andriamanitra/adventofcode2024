DIRECTIONS = (
    UP    = CartesianIndex(-1, 0),
    DOWN  = CartesianIndex(1, 0),
    LEFT  = CartesianIndex(0, -1),
    RIGHT = CartesianIndex(0, 1),
)

root(uf, idx) = idx == uf[idx] ? idx : root(uf, uf[idx])

function unite(uf, a, b)
    rt_a = root(uf, a)
    rt_b = root(uf, b)
    uf[rt_b] = rt_a
    uf[b] = rt_a
end

mutable struct Region
    color::Char
    area::Int
    perimeter::Int
    sides::Int
    Region(ch) = new(ch, 0, 0, 0)
end

function solve(grid)
    indices = collect(1 : reduce(*, size(grid)))
    uf = reshape(indices, size(grid))

    for idx in CartesianIndices(grid)
        color = grid[idx]
        for direction in DIRECTIONS
            neighbor = idx + direction

            if checkbounds(Bool, grid, neighbor) && grid[neighbor] == color
                unite(uf, idx, neighbor)
            end
        end
    end

    function iscorner(idx, d1, d2)
        this = grid[idx]
        nb1 = get(grid, idx + d1, nothing)
        nb2 = get(grid, idx + d2, nothing)
        diag = get(grid, idx + d1 + d2, nothing)
        (this != nb1 && this != nb2) || (this == nb1 && this == nb2 && this != diag)
    end

    regions = Dict{Int, Region}()
    for idx in CartesianIndices(grid)
        region_id = root(uf, idx)
        region = get!(regions, region_id, Region(grid[idx]))
        region.area += 1
        region.sides += iscorner(idx, DIRECTIONS.UP, DIRECTIONS.LEFT)
        region.sides += iscorner(idx, DIRECTIONS.UP, DIRECTIONS.RIGHT)
        region.sides += iscorner(idx, DIRECTIONS.DOWN, DIRECTIONS.LEFT)
        region.sides += iscorner(idx, DIRECTIONS.DOWN, DIRECTIONS.RIGHT)
        for direction in DIRECTIONS
            if grid[idx] != get(grid, idx + direction, nothing)
                region.perimeter += 1
            end
        end
    end

    price = sum(r.area * r.perimeter for r in values(regions))
    discounted_price = sum(r.area * r.sides for r in values(regions))
    println("Part 1: $price")
    println("Part 2: $discounted_price")
end

readlines("input.txt") |> stack |> solve
