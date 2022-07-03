module RectTest
    ( api
    ) where

import MaxRect
import UtilityTypes

api :: IO [Bin]
api = do
    r <- minimizeBins 840 670 testSizeList
    mapM_ print r
    return r
  where

l :: [Size]
l =
    [ Size 32 32
    , Size 16 32
    , Size 64 16
    , Size 64 32
    , Size 16 16
    ]

testSizeList :: [Size]
testSizeList =
    [ Size 128 126
    , Size 128 126
    , Size 128 126
    , Size 128 126
    , Size 128 126
    , Size 128 126
    , Size 114 74
    , Size 114 74
    , Size 114 74
    , Size 276 164
    , Size 276 164
    , Size 246 58
    , Size 78 118
    , Size 576 136
    , Size 178 26
    , Size 226 60
    , Size 34 30
    , Size 138 38
    , Size 114 202
    , Size 40 170
    , Size 126 50
    , Size 262 52
    , Size 116 138
    , Size 114 162
    , Size 158 108
    , Size 144 118
    , Size 144 100
    , Size 126 74
    , Size 176 86
    , Size 66 114
    , Size 186 132
    , Size 144 178
    , Size 218 180
    , Size 278 246
    , Size 188 332
    , Size 222 78
    , Size 220 240
    , Size 190 316
    , Size 146 128
    , Size 150 184
    , Size 184 180
    , Size 186 394
    , Size 292 208
    , Size 272 188
    , Size 136 284
    , Size 120 120
    , Size 120 120
    , Size 74 80
    , Size 116 106
    , Size 48 52
    , Size 36 38
    , Size 76 76
    , Size 78 72
    , Size 126 148
    , Size 120 38
    , Size 80 170
    , Size 54 56
    , Size 42 174
    , Size 116 166
    , Size 122 240
    , Size 112 162
    , Size 162 96
    , Size 240 70
    , Size 88 44
    , Size 122 174
    , Size 228 62
    , Size 128 214
    ]
