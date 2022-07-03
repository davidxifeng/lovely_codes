{-# LANGUAGE OverloadedStrings #-}
import System.ZMQ4.Monadic
import Control.Monad

import Data.IORef

-- SocketType : Req 模式

main = do
    putStrLn "zmq in Haskell"
    i <- newIORef 0
    runZMQ $ do
        s <- socket Req -- s :: (Socket z Req)
        --connect s "tcp://192.168.16.126:5555"
        connect s "tcp://localhost:5555"
        replicateM_ 10000 $ do
            send s [] "hello server"
            reply <- receive s
            liftIO $ modifyIORef' i (+1)
    readIORef i >>= print

