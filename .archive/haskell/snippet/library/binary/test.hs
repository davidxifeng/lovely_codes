import Data.Binary.Builder
import Data.Monoid
import qualified Data.Binary.Put as B

testBuilder = putWord16be 1 <> putWord32be 2 <> putWord64be 3

tb = toLazyByteString testBuilder

tp = B.runPut $ do
    B.putWord8 0
    B.putWord16be 1
    B.putWord64be 2
    B.putWord32be 3
