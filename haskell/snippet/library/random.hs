import Control.Monad.Random
import System.Random ()
import System.Random.Shuffle

testShuffle = shuffle "hello world" [0..11]

die :: (RandomGen g ) => Rand g Int
die = getRandomR (1, 6)

dice :: (RandomGen g) => Int -> Rand g [Int]
dice n = sequence (replicate n die)

main = do
        values <- evalRandIO (dice 8)
        putStrLn (show values)
