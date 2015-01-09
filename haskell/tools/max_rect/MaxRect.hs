{-# LANGUAGE ForeignFunctionInterface #-}
module MaxRect
    ( minimizeBins
    , maxRect
    ) where
import Foreign
import Foreign.C -- get the C types

import UtilityTypes

-- | 要求所有size必须小于等于最大bin size
minimizeBins :: Int -> Int -> [Size] -> IO [Bin]
minimizeBins mw mh sa = do
    ps <- new size
    pss <- newArray sa
    pr <- malloc
    prs <- malloc

    c_minimizeBins ps pss len pr prs

    ptr <- peek pr
    rlen <- peek prs
    rs <- peekArray (fromIntegral rlen) ptr
    c_freeBinResult ptr rlen

    free ps
    free pss
    free pr
    free prs

    return rs
  where
    len = fromIntegral $ length sa
    size = Size mw mh

foreign import ccall "MaxRect.h c_minimizeBins" c_minimizeBins :: Ptr Size
        -> Ptr Size -> CInt -> Ptr (Ptr Bin) -> Ptr CInt -> IO ()

foreign import ccall "MaxRect.h c_freeBinResult" c_freeBinResult :: Ptr Bin
        -> CInt -> IO ()

foreign import ccall "MaxRect.h maxRect" c_maxRect :: Ptr Size -> CInt
        -> Ptr Pos -> Ptr CInt -> Ptr CInt -> IO CInt

maxRect :: [Size] -> IO (Int, Int, [Pos])
maxRect sa = do
    s <- newArray sa
    p <- mallocArray len
    w <- malloc
    h <- malloc

    c_maxRect s (fromIntegral len) p w h

    rw <- peek w
    rh <- peek h
    r2 <- peekArray len p

    free s
    free p
    free w
    free h

    return (fromIntegral rw, fromIntegral rh, r2)
  where
    len = length sa

