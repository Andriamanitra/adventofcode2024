import System.IO (readFile')

type Pos = (Int, Int)
type Speed = (Int, Int)
data Robot = Robot Pos Speed deriving Show
data Quadrant = TopLeft | TopRight | BottomLeft | BottomRight | None deriving (Show, Eq)

parseRobot :: String -> Robot
parseRobot line = Robot pos speed
  where parsePairOfInts s = (read a, read b) where (a, (_:b)) = span (/= ',') s
        [pos, speed] = (parsePairOfInts . drop 2) <$> words line

getPos :: Robot -> Pos
getPos (Robot pos _) = pos

move :: Int -> Robot -> Robot
move steps (Robot (x, y) (dx, dy)) = Robot (x + steps * dx, y + steps * dy) (dx, dy)

onGrid :: (Int, Int) -> Pos -> Pos
onGrid (width, height) (x, y) = (mod x width, mod y height)

whichQuadrantOnGrid :: (Int, Int) -> Pos -> Quadrant
whichQuadrantOnGrid gridSize@(w, h) pos
  | x < xMid && y < yMid = TopLeft
  | x > xMid && y < yMid = TopRight
  | x < xMid && y > yMid = BottomLeft
  | x > xMid && y > yMid = BottomRight
  | otherwise = None
  where
    (x, y) = onGrid gridSize pos
    (xMid, yMid) = (div w 2, div h 2)

variance :: [Int] -> Int
variance xs = sum [(x - mean) ^ 2 | x <- xs]
  where mean = div (sum xs) (length xs)

xyVariance :: [Pos] -> Int
xyVariance positions = variance xs * variance ys
  where (xs, ys) = unzip positions

solvePart1 :: [Robot] -> (Int, Int) -> Int
solvePart1 robots gridSize = product $ countIn robotQuadrants <$> [TopLeft, TopRight, BottomLeft, BottomRight]
  where countIn xs x = length $ filter (==x) xs
        robotQuadrants = whichQuadrantOnGrid gridSize . getPos <$> robots

solvePart2 :: [Robot] -> (Int, Int) -> Int
solvePart2 robots gridSize@(width, height) = indexOfMinVariance
  where
    moveAll = map $ move 1
    loopLength = width * height
    getPosOnGrid = onGrid gridSize . getPos
    xyVariances = xyVariance . map getPosOnGrid <$> iterate moveAll robots
    (_, indexOfMinVariance) = minimum $ zip xyVariances [0..loopLength]

main = do
  input <- lines <$> readFile' "input.txt"
  let gridSize = (101, 103)
  let robots = parseRobot <$> input

  let safetyFactor = solvePart1 (move 100 <$> robots) gridSize
  putStrLn $ "Part 1: " <> show safetyFactor

  let easterEggAppearsAt = solvePart2 robots gridSize
  putStrLn $ "Part 2: " <> show easterEggAppearsAt
