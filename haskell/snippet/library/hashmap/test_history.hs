{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE FlexibleInstances #-}

import Data.HashMap.Strict (HashMap)
import Data.Aeson.Types
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import GHC.Generics
import Data.Map (Map)

import qualified Data.HashMap.Strict as HM
import qualified Data.Map as Map

data Person = Person
     { name :: String
     , age  :: Int
     } deriving (Show, Generic)

instance FromJSON Person
instance ToJSON Person

--instance FromJSON (HashMap String Person)
--instance ToJSON (HashMap String Person)

js = "{ \"name\": \"Joe\", \"age\": 12 }"

s :: Maybe Person
s = decode' js


ps = Person { name = "david"
            , age  = 27
            }


h :: Map String Person
h = Map.fromList [("david test", ps)]

t2 = encode ps

t :: ByteString
t = encode h

