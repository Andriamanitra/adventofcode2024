import System.IO (readFile')
import Data.Char (digitToInt)
import Data.List (nub)

type Pos = (Int, Int)

findTrailheads :: [[Int]] -> [[Pos]]
findTrailheads grid@(firstRow:_) = [search 0 (i, j) | i <- [0..iMax], j <- [0..jMax]]
  where
    iMax = length grid - 1
    jMax = length firstRow - 1
    inBounds (i, j) = 0 <= i && i <= iMax && 0 <= j && j <= jMax
    neighbors (i, j) = filter inBounds [(i+1, j), (i-1, j), (i, j+1), (i, j-1)]
    gridAt (i, j) = grid !! i !! j
    search h pos
      | gridAt pos /= h = []
      | h == 9 = [pos]
      | otherwise = concatMap (search (h+1)) $ neighbors pos

main = do
  input <- readFile' "input.txt"
  let grid = map digitToInt <$> lines input
  let trailheads = findTrailheads grid
  let part1 = sum $ length . nub <$> trailheads
  putStrLn $ "Part 1: " <> show part1
  let part2 = sum $ map length trailheads
  putStrLn $ "Part 2: " <> show part2
