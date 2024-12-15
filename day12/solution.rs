use std::io::BufRead;
use std::collections::BTreeSet;

type Position = (usize, usize);

struct Region {
    kind: char,
    positions: Vec<Position>,
}

struct Grid {
    width: usize,
    height: usize,
    grid: Vec<Vec<char>>,
}
impl Grid {
    fn regions(&self) -> Vec<Region> {
        let mut regions = vec![];
        let mut seen = vec![vec![false; self.width]; self.height];
        for r in 0..self.height {
            for c in 0..self.width {
                if seen[r][c] {
                    continue
                }
                seen[r][c] = true;
                let letter = self.grid[r][c];
                let mut region = vec![(r, c)];
                for i in 0.. {
                    let (r, c) = region[i];
                    if r > 0 && !seen[r-1][c] && self.grid[r-1][c] == letter {
                        region.push((r-1, c));
                        seen[r-1][c] = true;
                    }
                    if c > 0 && !seen[r][c-1] && self.grid[r][c-1] == letter {
                        region.push((r, c-1));
                        seen[r][c-1] = true;
                    }
                    if r < self.height - 1 && !seen[r+1][c] && self.grid[r+1][c] == letter {
                        region.push((r+1, c));
                        seen[r+1][c] = true;
                    }
                    if c < self.width - 1 && !seen[r][c+1] && self.grid[r][c+1] == letter {
                        region.push((r, c+1));
                        seen[r][c+1] = true;
                    }
                    if i + 1 >= region.len() {
                        break
                    }
                }
                regions.push(Region { kind: letter, positions: region });
            }
        }
        regions
    }
}

fn read_grid<P: AsRef<std::path::Path>>(fname: P) -> std::io::Result<Grid> {
    let file = std::fs::File::open(fname)?;
    let reader = std::io::BufReader::new(file);
    let mut grid: Vec<Vec<char>> = vec![];
    for line in reader.lines() {
        grid.push(line?.chars().collect())
    }
    let width = grid[0].len();
    let height = grid.len();
    Ok(Grid { width, height, grid })
}

fn fence_cost(region: &Region) -> usize {
    let set: BTreeSet<_> = region.positions.iter().collect();
    let mut edges = 0;
    for &(i, j) in &region.positions {
        edges += (i < 1 || !set.contains(&(i-1, j))) as usize;
        edges += (j < 1 || !set.contains(&(i, j-1))) as usize;
        edges += (!set.contains(&(i+1, j))) as usize;
        edges += (!set.contains(&(i, j+1))) as usize;
    }

    if let Ok(_) = std::env::var("DEBUG") {
        eprintln!("{}: {} * {}", region.kind, region.positions.len(), edges);
    }

    region.positions.len() * edges
}
fn discounted_fence_cost(region: &Region) -> usize {
    let set: BTreeSet<_> = region.positions.iter().map(|(i,j)| (*i as i32, *j as i32)).collect();
    let mut sides = 0;
    for &(x, y) in &set {
        for (dx, dy) in [(-1,-1), (-1,1), (1,-1), (1,1)] {
            let b = set.contains(&(x + dx, y));
            let c = set.contains(&(x, y + dy));
            let d = set.contains(&(x + dx, y + dy));
            sides += (b == c && (!b || !d)) as usize;
        }
    }

    if let Ok(_) = std::env::var("DEBUG") {
        eprintln!("{}: {} * {}", region.kind, region.positions.len(), sides);
    }

    region.positions.len() * sides
}

fn main() -> std::io::Result<()> {
    let input_filename = std::env::args().nth(1).unwrap_or(String::from("input.txt"));
    let grid = read_grid(input_filename)?;
    let regions = grid.regions();

    let total_fence_cost: usize = regions.iter().map(fence_cost).sum();
    println!("Part 1: {}", total_fence_cost);

    let discounted_total_fence_cost: usize = regions.iter().map(discounted_fence_cost).sum();
    println!("Part 2: {}", discounted_total_fence_cost);

    Ok(())
}
