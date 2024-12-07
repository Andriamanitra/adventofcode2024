fn part1(grid: &[&[u8]]) -> usize {
    const DIRECTIONS: [(i32, i32); 8] = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)];
    let height = grid.len() as i32;
    let width = grid[0].len() as i32;
    let mut count = 0;
    for r in 0..height {
        for c in 0..width {
            for (dr, dc) in DIRECTIONS {
                count += "XMAS".bytes().enumerate().all(|(i, letter)| {
                    let r = r + i as i32 * dr;
                    let c = c + i as i32 * dc;
                    0 <= r && r < height
                    && 0 <= c && c < width
                    && grid[r as usize][c as usize] == letter
                }) as usize;
            }
        }
    }
    count
}

fn part2(grid: &[&[u8]]) -> usize {
    const DIAGONALS: [[(i32, i32); 3]; 2] =[
        [(-1, -1), (0, 0), (1, 1)],
        [(1, -1), (0, 0), (-1, 1)],
    ];
    let mut count = 0;
    let height = grid.len() as i32;
    let width = grid.len() as i32;
    for r in 1..height - 1 {
        for c in 1..width - 1 {
            count += (
                grid[r as usize][c as usize] == b'A'
                && DIAGONALS.iter().all(|[(dr1, dc1), _, (dr2, dc2)]| {
                    let (r1, c1) = ((r + dr1) as usize, (c + dc1) as usize);
                    let (r2, c2) = ((r + dr2) as usize, (c + dc2) as usize);
                    matches!((grid[r1][c1], grid[r2][c2]), (b'M', b'S') | (b'S', b'M'))
                })
            ) as usize;
        }
    }
    count
}

fn main() -> std::io::Result<()> {
    let input = std::fs::read_to_string("input.txt")?;
    let grid: Vec<_> = input.lines().map(str::as_bytes).collect();

    let xmas_count = part1(&grid);
    println!("Part 1: {xmas_count}");
    let x_mas_count = part2(&grid);
    println!("Part 2: {x_mas_count}");
    Ok(())
}
