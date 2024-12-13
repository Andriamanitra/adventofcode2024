import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map, (!?))
import qualified Data.Set as Set
import Data.Set (Set)
import System.IO (readFile')

data Pos = P Int Int deriving (Show, Ord, Eq)
data Direction = North | East | South | West deriving (Eq, Ord, Enum, Bounded, Show)
type Grid a = Map Pos a
type Region = Set Pos
data Edge = Edge Pos Direction deriving (Show, Ord, Eq)

makeGrid :: String -> Grid Char
makeGrid s = Map.fromList
  [ (P x y, color)
  | (line, y) <- zip (lines s) [1..]
  , (color, x) <- zip line [1..]
  ]

neighbors :: Pos -> [Pos]
neighbors pos = [move d pos | d <- [minBound..maxBound]]

move :: Direction -> Pos -> Pos
move North (P x y) = P x (y-1)
move East  (P x y) = P (x+1) y
move South (P x y) = P x (y+1)
move West  (P x y) = P (x-1) y

rot90 :: Direction -> Direction
rot90 x = if x == maxBound then minBound else succ x

regionsOf :: Eq a => Grid a -> [Region]
regionsOf grid = go (Map.keys grid) mempty mempty
  where
    go :: [Pos] -> Set Pos -> [Region] -> [Region]
    go [] _ g = g
    go (p:ps) visited regions
      | Set.member p visited = go ps visited regions
      | otherwise = go ps (Set.union visited region) (region:regions)
      where region = floodfillFrom p mempty
    floodfillFrom :: Pos -> Set Pos -> Set Pos
    floodfillFrom p region
      | Set.member p region = region
      | otherwise = recur $ Set.insert p region
      where
        sameColor npos = (grid!?p) == (grid!?npos)
        recur = foldl (.) id $ floodfillFrom <$> filter sameColor (neighbors p)

edgesOf :: Region -> Set Edge
edgesOf region = Set.fromList
  [ Edge pos direction
  | pos <- Set.elems region
  , direction <- [minBound..maxBound]
  , Set.notMember (move direction pos) region
  ]

sidesOf :: Region -> Set Edge
sidesOf region = Set.filter ((`Set.notMember` edges) . adjacentEdge) edges
  where
    edges = edgesOf region
    adjacentEdge (Edge pos d) = Edge (move (rot90 d) pos) d

fenceCostPart1 :: Region -> Int
fenceCostPart1 region = length region * length (edgesOf region)

fenceCostPart2 :: Region -> Int
fenceCostPart2 region = length region * length (sidesOf region)

main :: IO ()
main = do
  input <- readFile' "input.txt"
  let grid = makeGrid input
  let regions = regionsOf grid
  let part1 = sum $ fenceCostPart1 <$> regions
  putStrLn $ "Part 1: " <> show part1
  let part2 = sum $ fenceCostPart2 <$> regions
  putStrLn $ "Part 2: " <> show part2
