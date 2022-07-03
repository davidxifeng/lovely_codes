{-# LANGUAGE RecordWildCards #-}


import Data.Map

data Lily = Lily
          { name :: String
          , tel :: Integer
          }
          deriving (Show)

lily :: Lily
lily = Lily "lily" 521

ioLily :: IO Lily
ioLily = return lily
