import System.IO.Unsafe
import Data.IORef

{-# NOINLINE globalVar #-}
globalVar :: IORef [Int]
globalVar = unsafePerformIO $ newIORef [521]

{-# NOINLINE gv2 #-}
gv2 :: IORef Int
gv2 = unsafePerformIO $ do
    r <- newIORef 2
    writeIORef r 8
    return r

main :: IO ()
main = do
        t <- readIORef globalVar
        print t
        writeIORef globalVar (t ++ [1314])
        t <- readIORef globalVar
        print t
        readIORef gv2 >>= print

