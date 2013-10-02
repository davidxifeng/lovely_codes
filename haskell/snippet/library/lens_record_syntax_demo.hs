{-# LANGUAGE TemplateHaskell #-}

import Control.Lens


data Love = Love
          { _a :: Int
          , _b :: Smile
          }
          deriving (Show)

data Smile = Smile
           { _c :: Int
           }
           deriving (Show)

makeLenses ''Love
makeLenses ''Smile

t = Love { _a = 1
         , _b = Smile { _c = 2}
         }

tbc = t ^. b.c

