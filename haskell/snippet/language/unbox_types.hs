{-# LANGUAGE MagicHash #-}
import Data.List
import Data.IORef
import Data.Int

import GHC.Prim
import GHC.Types

main = print $ I# (myadd 1# 0#)

myadd :: Int# -> Int# -> Int#
myadd i r =
    if i <=# 1000000000#
    then myadd (i +# 1#) (i +# r)
    else r
