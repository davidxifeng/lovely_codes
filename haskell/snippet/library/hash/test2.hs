
import qualified Data.HashTable.IO as H
import Data.Int
import Text.Printf (printf)
import Control.Monad
import Data.IntSet (IntSet)
import qualified Data.IntSet as S
import Data.IORef

type HashTableB k v = H.BasicHashTable k v
type HT = HashTableB Int String

test :: IO (HT, IORef IntSet)
test = do
    a <- H.newSized 2000000
    b <- newIORef S.empty
    return (a, b)

ist ht = forM_ [1 .. 1870500] (f ht)

f :: (HT, IORef IntSet) -> Int -> IO ()
f (a, b) i = do
    H.insert a i (show i)
    is <- readIORef b
    let ns = S.insert i is
    ns `seq` writeIORef b ns


ist2 ht = forM_ [1 .. 80000] (f ht)

main :: IO ()
main = do
    ht <- test
    ist2 ht
    ist ht
    is <- readIORef (snd ht)
    putStrLn $ "size is " ++ show (S.size is)


p :: (Int32, String) -> IO ()
p (k, v) = putStrLn $ printf "key: %d value: %s" k v


