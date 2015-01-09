{-# LANGUAGE OverloadedStrings #-}
module UtilityTypes ( -- ** Pos类型
                      Size(..)
                    , Pos(..)
                    , RectInfo(..)
                    , Bin(..)
                    ) where
import Foreign
import Foreign.C

import Data.List

import Data.Aeson

data Size
    = Size { width  :: {-# UNPACK #-} !Int
           , height :: {-# UNPACK #-} !Int
           } deriving (Show)

instance Storable Size where
    sizeOf _ = sizeOf (undefined :: CInt) * 2
    alignment _ = 1
    peek p = do
        let ptr = castPtr p :: Ptr CInt
        w <- peekElemOff ptr 0
        h <- peekElemOff ptr 1
        return $ Size (fromIntegral w) (fromIntegral h)

    poke p (Size w h) = do
        let ptr = castPtr p :: Ptr CInt
        pokeElemOff ptr 0 (fromIntegral w)
        pokeElemOff ptr 1 (fromIntegral h)

-- | pasteImage 的参数
data Pos
    = Pos { -- | x坐标
            posX      :: {-# UNPACK #-} !Int
            -- | y坐标
          , posY      :: {-# UNPACK #-} !Int
            -- | 是否顺时针90度翻转图片
          , isRotated :: !Bool
          } deriving (Show)

instance Storable Pos where
    sizeOf _ = sizeOf (undefined :: CInt) * 3
    alignment _ = 1
    peek p = do
        let ptr = castPtr p :: Ptr CInt
        x <- peekElemOff ptr 0
        y <- peekElemOff ptr 1
        r <- peekElemOff ptr 2
        return $ Pos (fromIntegral x) (fromIntegral y) (r /= 0)

    poke p (Pos x y r)= do
        let ptr = castPtr p :: Ptr CInt
            bi True  = 1
            bi False = 0
        pokeElemOff ptr 0 (fromIntegral x)
        pokeElemOff ptr 1 (fromIntegral y)
        pokeElemOff ptr 2 (bi r)

data RectInfo
    = RectInfo { riX :: !Int
               , riY :: !Int
               , riW :: !Int
               , riH :: !Int
               , riR :: Bool
               , riI :: !Int
               } deriving (Show)

instance Storable RectInfo where
    sizeOf _ = sizeOf (undefined :: CInt) * 6
    alignment _ = 1
    poke _ _ = undefined
    peek p = do
        let ptr = castPtr p :: Ptr CInt
        x <- peekElemOff ptr 0
        y <- peekElemOff ptr 1
        w <- peekElemOff ptr 2
        h <- peekElemOff ptr 3
        r <- peekElemOff ptr 4
        i <- peekElemOff ptr 5
        return RectInfo { riX = fromIntegral x
                        , riY = fromIntegral y
                        , riW = fromIntegral w
                        , riH = fromIntegral h
                        , riR = r /= 0
                        , riI = fromIntegral i
                        }

instance ToJSON RectInfo where
    toJSON (RectInfo x y w h r i) = object
        [ "x" .= x
        , "y" .= y
        , "w" .= w
        , "h" .= h
        , "r" .= r
        , "i" .= i
        ]

data Bin
    = Bin { bWidth  :: !Int
          , bHeight :: !Int
          , bPos    :: [RectInfo]
          }

instance ToJSON Bin where
    toJSON (Bin w h rl) = object
        [ "width"  .= w
        , "height" .= h
        , "rects"  .= rl
        ]

instance Show Bin where
    show (Bin w h pl) =
        "width: " ++ show w ++ "\n" ++
        "height: " ++ show h ++ "\n" ++
        (intercalate "\n" . map show $ pl)

instance Storable Bin where
    sizeOf _ = 24 -- padding TODO: hsc
    alignment _ = 1
    poke _ (Bin _ _ _) = undefined
    peek p = do
        let ptr = castPtr p :: Ptr CInt
        w <- peekElemOff ptr 0
        h <- peekElemOff ptr 1
        c <- peekElemOff ptr 2
        let p2 = plusPtr p 16 :: Ptr (Ptr RectInfo)
        pPos <- peek p2
        a <- peekArray (fromIntegral c) pPos
        return Bin { bWidth  = fromIntegral w
                   , bHeight = fromIntegral h
                   , bPos    = a
                   }


