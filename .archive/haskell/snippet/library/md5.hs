{-# LANGUAGE OverloadedStrings #-}
import Crypto.Hash.MD5
import qualified Data.ByteString as B

-- cabal install bytedump
import Text.Bytedump

i = "love you"

li = "love you"

hi = hash i

hli = hashlazy li

t = map hexString $ B.unpack hi

dr = dumpRaw $ B.unpack hi

tdd = dumpDiff (B.unpack $ hash "love") (B.unpack $ hash "l0ve")
tdd' = dumpDiff (B.unpack "love") (B.unpack "l0ve")
