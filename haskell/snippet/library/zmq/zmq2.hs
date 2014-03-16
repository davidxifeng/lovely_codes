{-# LANGUAGE OverloadedStrings #-}
import System.ZMQ4
import Control.Monad

import Data.IORef

-- SocketType : Req 模式

main = do
    putStrLn "zmq in Haskell"
    i <- newIORef 0

    ctx <- context
    s <- socket ctx Req
    connect s "tcp://localhost:5555"

    replicateM_ 10 $ do
        send s [] "hello server"
        receive s >>= print
        modifyIORef' i (+1)

    close s -- term前要close socket,否则term会block
    shutdown ctx -- 先shutdown 再term 另外还有一个被废弃的API destroy
    term ctx
    readIORef i >>= print

