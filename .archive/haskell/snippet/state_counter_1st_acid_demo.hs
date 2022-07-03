{-# LANGUAGE CPP, DeriveDataTypeable, FlexibleContexts, GeneralizedNewtypeDeriving, 
  MultiParamTypeClasses, TemplateHaskell, TypeFamilies, RecordWildCards #-}

module Main where

import Control.Applicative  ( (<$>) )
import Control.Exception    ( bracket )
import Control.Monad        ( msum )
import Control.Monad.Reader ( ask )
import Control.Monad.State  ( get, put )
import Data.Data            ( Data, Typeable )
import Happstack.Server     ( Response, ServerPart, dir, nullDir, nullConf, ok
                            , simpleHTTP, toResponse )
import Data.Acid            ( AcidState, Query, Update, makeAcidic )
import Data.Acid.Advanced   ( query', update' )
import Data.Acid.Local      ( openLocalState, createCheckpointAndClose )
import Data.SafeCopy        ( base, deriveSafeCopy )


data CounterState = CounterState { count :: Integer }
    deriving (Eq, Ord, Read, Show, Data, Typeable)

$(deriveSafeCopy 0 'base ''CounterState)

initialCounterState :: CounterState
initialCounterState = CounterState 0

incCountBy :: Integer -> Update CounterState Integer
incCountBy n =
    do c@CounterState{..} <- get
       let newCount = count + n
       put $ c { count = newCount }
       return newCount

peekCount :: Query CounterState Integer
peekCount = count <$> ask

$(makeAcidic ''CounterState ['incCountBy, 'peekCount])

handlers :: AcidState CounterState -> ServerPart Response
handlers acid =
    msum [ dir "peek" $ do c <- query' acid PeekCount
                           ok $ toResponse $ "peeked at the count and saw: " ++ show c
         , do nullDir
              c <- update' acid (IncCountBy 1)
              ok $ toResponse $ "New count is: " ++ show c

         ]

main :: IO ()
main =
    do bracket (openLocalState initialCounterState)
               (createCheckpointAndClose)
               (\acid ->
                    simpleHTTP nullConf (handlers acid))
