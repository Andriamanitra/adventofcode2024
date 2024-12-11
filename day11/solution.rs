use std::io::prelude::*;
use std::collections::*;

type Stone = u64;
type Day11Input = Vec<Stone>;

trait ReadDay11Input {
    fn read_input(&mut self) -> std::io::Result<Day11Input>;
}

impl<T: Read> ReadDay11Input for T {
    fn read_input(&mut self) -> std::io::Result<Day11Input> {
        let mut buf = String::new();
        self.read_to_string(&mut buf)?;
        let nums: Result<Day11Input, _> = buf.split_whitespace().map(str::parse).collect();
        Ok(nums.expect("input should be space-separated list of unsigned integers"))
    }
}

fn solve(nums: &Day11Input, blinks: usize) -> usize {
    let mut counts: HashMap<Stone, usize> = HashMap::new();
    for num in nums {
        *counts.entry(*num).or_insert(0) += 1;
    }
    const TEN: Stone = 10;
    for _ in 0..blinks {
        let old_counts = counts.iter().map(|(k, v)| (*k, *v)).collect::<Vec<_>>();
        counts.clear();
        for (k, count) in old_counts {
            // If the stone is engraved with the number 0, it is
            // replaced by a stone engraved with the number 1.
            if k == 0 {
                *counts.entry(1).or_insert(0) += count;
                continue
            }

            // If the stone is engraved with a number that has an
            // even number of digits, it is replaced by two stones
            let num_digits = k.ilog10() + 1;
            if num_digits & 1 == 0 {
                let pow = TEN.pow(num_digits / 2);
                let left = k / pow;
                let right = k.rem_euclid(pow);
                *counts.entry(left).or_insert(0) += count;
                *counts.entry(right).or_insert(0) += count;
                continue
            }

            // Otherwise, the stone is replaced by a new stone; the new
            // stone's number is old stone's number multiplied by 2024
            let num = 2024 * k;
            *counts.entry(num).or_insert(0) += count;
        }
    }
    counts.values().sum()
}

fn main() -> std::io::Result<()> {
    let input = match std::env::args().nth(1) {
        Some(ref value) if value == "--example" => vec![125, 17],
        Some(fname) => std::fs::File::open(fname)?.read_input()?,
        None => std::io::stdin().read_input()?,
    };
    println!("input = {:?}", input);
    println!("Part 1: {}", solve(&input, 25));
    println!("Part 2: {}", solve(&input, 75));
    Ok(())
}