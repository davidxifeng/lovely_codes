import Control.Concurrent.MVar
import qualified Data.Map as M
import System.IO.Unsafe (unsafePerformIO)

import Data.List


memoIO :: (Ord a) =>
    (a -> b) -> IO (a -> IO b)

memoIO f = do
    v <- newMVar M.empty
    let f' x = do
            m <- readMVar v
            case M.lookup x m of
                Nothing -> do
                    let r = f x
                    modifyMVar_ v (return . M.insert x r)
                    return r
    return f'

memo :: (Ord a) => (a -> b) -> (a -> b)
memo f = let f' = unsafePerformIO (memoIO f) in \x -> unsafePerformIO (f' x)


main :: IO ()
main = test

arg = subsequences [1..15]

f = length
mf = memo f

test = do
    let s = map mf arg
    print s
    print s

