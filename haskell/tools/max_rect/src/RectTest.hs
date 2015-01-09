module RectTest
    ( api
    ) where

import MaxRect
import UtilityTypes

api :: IO [Bin]
api = do
    r <- minimizeBins 256 256 l
    mapM_ print r
    return r
  where
    l =
        [ Size 32 32
        , Size 16 32
        , Size 64 16
        , Size 64 32
        , Size 16 16
        ]

