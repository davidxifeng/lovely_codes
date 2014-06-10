{-# LANGUAGE MagicHash #-}
import Data.List
import Data.IORef
import Data.Int

import GHC.Prim
import GHC.Types

main = print I# $ myadd 1# 0#

myadd :: Int# -> Int# -> Int#
myadd i r =
    if i <=# 10000000000#
    then myadd (i +# 1#) (i +# r)
    else r

add :: IO ()
add = do
    i <- newIORef (1 :: Int)
    r <- newIORef 0
    loop i r
  where
    loop ir rr = do
        i <- readIORef ir
        if i <= maxv
        then do
            r <- readIORef rr
            (i + r) `seq` atomicWriteIORef rr (i + r)
            (i + 1) `seq` atomicWriteIORef ir (i + 1)
            loop ir rr
        else do
            r <- readIORef rr
            putStrLn $ "r is " ++ show r

