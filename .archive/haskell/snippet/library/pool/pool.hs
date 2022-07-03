import Data.Pool
import Data.IORef
import Control.Concurrent
import Control.Monad

import Data.Time.Clock



type IntPool = Pool Int

createI :: IORef Int -> IO Int
createI ioi = do
    i <- readIORef ioi
    atomicModifyIORef' ioi (\ i -> (i + 1, ()))
    return i

destroyI :: Int -> IO ()
destroyI i = putStrLn $ "destroy i: " ++ show i

test :: IO ()
test = do
    ioi <- newIORef 0
    ip <- createPool (createI ioi) destroyI 1 8 2
    testUsePool ip

testUsePool :: Pool Int -> IO ()
testUsePool pool = mapM_ g [1..5]
  where
    g :: Int -> IO ()
    g i = do
        forkIO $ withResource pool  f
        putStrLn $ "pool: " ++ show pool
        return ()

    f :: Int -> IO ()
    f i = do
        tid <- myThreadId
        putStrLn $ "forkIO use resource i: " ++ show i ++ show tid
        --threadDelay 500000
        putStrLn $ "forkIO use resource end i: " ++ show i
