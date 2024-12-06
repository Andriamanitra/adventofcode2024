use std::io::prelude::*;

type Page = usize;
type Dependencies = [[bool; 100]; 100];
type Update = Vec<Page>;

#[derive(Debug)]
struct Day5Input {
    dependencies: Dependencies,
    updates: Vec<Update>,
}

fn read_input(fname: &str) -> std::io::Result<Day5Input> {
    let input_file = std::fs::File::open(fname)?;
    let reader = &mut std::io::BufReader::new(input_file);

    let mut dependencies: Dependencies = [[false; 100]; 100];
    for line in reader.lines() {
        let line = line?;
        if line.is_empty() {
            break;
        }
        let (a, b) = line.split_once('|').unwrap();
        let a: Page = a.parse().unwrap();
        let b: Page = b.parse().unwrap();
        dependencies[a][b] = true;
    }

    let mut updates = vec![];
    for line in reader.lines() {
        let update = line?.split(',').map(|s| s.parse().unwrap()).collect();
        updates.push(update);
    }

    Ok(Day5Input { dependencies, updates })
}

fn main() -> std::io::Result<()> {
    let input = read_input("input.txt")?;
    let (mut part1, mut part2) = (0, 0);
    for update in &input.updates {
        let ordered = {
            let mut update = update.clone();
            // actually not sure if the subgraphs are guaranteed to have
            // total ordering but this works on my input...
            update.sort_by(|&a, &b| {
                match input.dependencies[a][b] {
                    true => std::cmp::Ordering::Less,
                    false if input.dependencies[b][a] => std::cmp::Ordering::Greater,
                    false => std::cmp::Ordering::Equal,
                }
            });
            update
        };

        let middle_page = ordered[ordered.len() / 2];
        if update == &ordered {
            part1 += middle_page;
        } else {
            part2 += middle_page;
        }
    }
    println!("Part 1: {}", part1);
    println!("Part 2: {}", part2);
    Ok(())
}
