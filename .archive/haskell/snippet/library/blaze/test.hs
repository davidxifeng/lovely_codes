import Blaze.ByteString.Builder
import Data.Monoid

import Blaze.ByteString.Builder.Char.Utf8
import qualified Data.ByteString.Lazy as BL

str :: String
str = "Hello 你好, 世界"

main :: IO ()
main = do
    BL.writeFile "test.txt" $ toLazyByteString builder

builder :: Builder
builder = fromString str <> fromStorable (1 :: Int) <> fromStorable (1 :: Float)
