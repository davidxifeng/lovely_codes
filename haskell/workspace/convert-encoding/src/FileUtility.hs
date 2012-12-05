module FileUtility(processDirectoryList,
        whenM, getDirectoryContentsEx, partitionM)
        where

-- Wed Dec  5 22:55:09 CST 2012

import Prelude() --hiding everything
import GHC.Base
import GHC.IO
import GHC.List
-- import GHC.Show(show)
-- import Data.Tuple
-- import System.IO(putStrLn)

import System.Directory(
    doesDirectoryExist, getDirectoryContents
    -- doesFileExist,
    -- createDirectory, removeFile, renameFile,
    -- removeDirectoryRecursive
    )
import System.FilePath((</>)) -- splitExtension
import Data.List(sort, delete)
import Control.Monad(when, mapM_, foldM) -- liftM, filterM


whenM :: Monad m => m Bool -> m () -> m ()
whenM s r = s >>= flip when r
{-
when              :: (Monad m) => Bool -> m () -> m ()
when p s          =  if p then s else return ()

whenM' s r = do {b <- s; when b r;}
whenM'' s r = do
        b <- s
        flip when r b
whenM''' s r = s >>= \x -> when x r
-}

selectM :: Monad m => (a -> m Bool) -> ([a], [a]) -> a -> m ([a], [a])
selectM p ~(ts,fs) x = do
        r <- p x
        if r then return (x:ts, fs) else return (ts, x:fs)
{-
foldM             :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
foldM _ a []      =  return a
foldM f a (x:xs)  =  f a x >>= \fax -> foldM f fax xs
-}
partitionM :: Monad m => (a -> m Bool) -> [a] -> m ([a],[a])
{-# INLINE partitionM #-}
partitionM p xs = do
        foldM (selectM p ) ([],[]) xs
-- foldM :: Monad m => (a -> b -> m a) -> a -> [b] -> m a
{-
        getDirectoryContents的加强版,返回子目录和子文件(完整路径名,不包括.和..)
        假定:获取的内容中,不是目录的就一定是文件(去掉了一个判断)
-}
getDirectoryContentsEx :: FilePath -> IO ([FilePath], [FilePath])
getDirectoryContentsEx dir = do
    r <- doesDirectoryExist dir
    if r
        then do
        dc <- getDirectoryContents dir
        -- dirs <- filterM doesDirectoryExist $ map (dir </>) (filter (\ x -> x /= "." && x /= "..") dc)
        -- dirs <- filterM doesDirectoryExist $ map (dir </>) [ x | x<- dc, x /= "..", x /= "."]
        (dirs,files) <- partitionM doesDirectoryExist $ map (dir </>) (delete "." (delete ".." $ sort dc))
        return (dirs, files)
        else do
        return ([], [])

{-
        输入一个过滤处理文件的判断函数,和一个处理文件的函数,一个待处理的目录列表;
        本函数会对目录下的所有判断为true子文件应用action
-}
-- processDirectoryList :: Monad m => (a -> m b) -> [a] -> m ()
-- |note:存在指向本目录的soft link情况下,有些文件可能会被处理两次
processDirectoryList :: (FilePath -> Bool) -> (FilePath -> IO ()) -> [FilePath] -> IO ()
processDirectoryList _ _ [] = return ()
processDirectoryList p action (dir:dirs) =
        whenM (doesDirectoryExist dir)
                (do
                (ds, fs) <- getDirectoryContentsEx dir
                mapM_ action $ filter p fs
                processDirectoryList p action ds
                )
        >>
        processDirectoryList p action dirs

{-
mapM_ :: Monad m => (a -> m b) -> [a] -> m ()
mapM_ f ac =  sequence_ (map f ac)
-}
