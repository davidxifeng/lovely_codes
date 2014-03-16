{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}

import Data.HashMap.Strict (HashMap)
import Data.Aeson.Types
--import Data.Aeson
import Data.Aeson.Generic
import Data.ByteString.Lazy (ByteString)
import GHC.Generics
import Data.Map (Map)
import Data.Typeable
import Data.Data

import qualified Data.HashMap.Strict as HM
import qualified Data.Map as Map

data Person = Person
     { name :: String
     , age  :: Int
     } deriving (Show, Generic, Typeable, Data)

instance FromJSON Person
instance ToJSON Person

js = "{ \"name\": \"Joe\", \"age\": 12 }"

s :: Maybe Person
s = decode' js


ps = Person { name = "david"
            , age  = 27
            }
psj = encode ps


h :: Map String Person
h = Map.fromList [("david test", ps)]
t :: ByteString
t = encode h

h2 :: HashMap String Person
h2 = HM.fromList [("test hash map", ps)]
t2 :: ByteString
t2 = encode h2
