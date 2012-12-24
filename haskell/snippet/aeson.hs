{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
import Data.Aeson
import Data.Aeson.Encode

import qualified Data.ByteString.Lazy.UTF8 as BSL.UTF8

import Data.Map

-- Sun Dec  9 14:41:00 CST 2012

h :: String -> BSL.UTF8.ByteString
h = BSL.UTF8.fromString

t1 = encode ([1..5]::[Integer])

t2 :: Maybe [Int]
t2 = decode t1 

t3 :: Maybe [Int]
t3 = decode (BSL.UTF8.fromString "[1,2,3]")

t4 :: Maybe (Map String Int)
t4 = decode (h "{\"test\" : 123456}")

t5 :: Maybe Value
t5 = decode (h "{\"test\" : 123456}")

main :: IO ()
main = do
    putStrLn "hi"
