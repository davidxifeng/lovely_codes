{-# LANGUAGE OverloadedStrings #-}
import System.ZMQ4.Monadic
import Control.Monad

import Data.IORef

-- SocketType : Req 模式

main = do
    putStrLn "zmq in Haskell"
    runZMQ $ do
        s <- socket Rep -- s :: (Socket z Req)
        bind s "tcp://*:5555"
        forever $ do
            reply <- receive s
            send s [] "hello server"

