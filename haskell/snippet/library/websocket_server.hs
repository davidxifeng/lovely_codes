{-# LANGUAGE OverloadedStrings #-}

import Data.Char (isPunctuation, isSpace)
import Data.Monoid (mappend)
import Data.Text (Text)
import Control.Exception (fromException, handle)
import Control.Monad (forM_, forever)
import Control.Concurrent (MVar, newMVar, modifyMVar_, readMVar)
import Control.Monad.IO.Class (liftIO)
import qualified Data.Text as T
import qualified Data.Text.IO as T

import qualified Network.WebSockets as WS

type Client = (Text, WS.Connection)


type ServerState = [Client]


newServerState :: ServerState
newServerState = []


numClients :: ServerState -> Int
numClients = length


clientExists :: Client -> ServerState -> Bool
clientExists client = any ((== fst client) . fst)


addClient :: Client -> ServerState -> ServerState
addClient client clients = client : clients


removeClient :: Client -> ServerState -> ServerState
removeClient client = filter ((/= fst client) . fst)


broadcast :: Text -> ServerState -> IO ()
broadcast message clients = do
    T.putStrLn message
    forM_ clients $ \(_, conn) -> WS.sendTextData conn message


main :: IO ()
main = do
    state <- newMVar newServerState
    WS.runServer "0.0.0.0" 9160 $ application state


application :: MVar ServerState -> WS.ServerApp
application state pending = do
    conn <- WS.acceptRequest pending
    msg <- WS.receiveData conn
    clients <- liftIO $ readMVar state
    case msg of
        _   | not (prefix `T.isPrefixOf` msg) ->
                WS.sendTextData conn ("Wrong announcement" :: Text)

            | any ($ fst client)
                [T.null, T.any isPunctuation, T.any isSpace] ->
                    WS.sendTextData conn ("Name cannot " `mappend`
                        "contain punctuation or whitespace, and " `mappend`
                        "cannot be empty" :: Text)

            | clientExists client clients ->
                WS.sendTextData conn ("User already exists" :: Text)

            | otherwise -> do
               liftIO $ modifyMVar_ state $ \s -> do
                   let s' = addClient client s
                   WS.sendTextData conn $
                       "Welcome! Users: " `mappend`
                       T.intercalate ", " (map fst s)
                   broadcast (fst client `mappend` " joined") s'
                   return s'
               talk conn state client
          where
            prefix = "Hi! I am "
            client = (T.drop (T.length prefix) msg, conn)

talk :: WS.Connection -> MVar ServerState -> Client -> IO ()
talk conn state client@(user, _) = handle catchDisconnect $
    forever $ do
        msg <- WS.receiveData conn
        liftIO $ readMVar state >>= broadcast
            (user `mappend` ": " `mappend` msg)
  where
    catchDisconnect e = case fromException e of
        Just WS.ConnectionClosed -> liftIO $ modifyMVar_ state $ \s -> do
            let s' = removeClient client s
            broadcast (user `mappend` " disconnected") s'
            return s'
        _ -> return ()
