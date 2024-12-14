import System.IO (readFile')
import Data.List (groupBy)

type Pos = (Int, Int)
type Speed = (Int, Int)
data Robot = Robot Pos Speed deriving Show
data Quadrant = TopLeft | TopRight | BottomLeft | BottomRight | None deriving (Show, Eq)

parseRobot :: String -> Robot
parseRobot line = Robot pos speed
  where parsePairOfInts s = (read a, read b) where (a, (_:b)) = span (/= ',') s
        [pos, speed] = (parsePairOfInts . drop 2) <$> words line

move :: Int -> Robot -> Robot
move steps (Robot (x, y) (dx, dy)) = Robot (x + steps * dx, y + steps * dy) (dx, dy)

onGrid :: (Int, Int) -> Robot -> Robot
onGrid (width, height) (Robot (x, y) speed) = Robot (mod x width, mod y width) speed

whichQuadrantOnGrid :: (Int, Int) -> Robot -> Quadrant
whichQuadrantOnGrid (width, height) (Robot (x, y) _)
  | xOnGrid < xMid && yOnGrid < yMid = TopLeft
  | xOnGrid > xMid && yOnGrid < yMid = TopRight
  | xOnGrid < xMid && yOnGrid > yMid = BottomLeft
  | xOnGrid > xMid && yOnGrid > yMid = BottomRight
  | otherwise = None
  where
    xMid = div width 2
    yMid = div height 2
    xOnGrid = mod x width
    yOnGrid = mod y height

main = do
  input <- lines <$> readFile' "input.txt"
  let robots = parseRobot <$> input
  let quadrants = whichQuadrantOnGrid (101, 103) . move 100 <$> robots
  let countIn xs x = length $ filter (==x) xs
  let part1 = product $ map (countIn quadrants) [TopLeft, TopRight, BottomLeft, BottomRight]
  print part1
