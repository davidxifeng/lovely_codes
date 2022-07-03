module Main where
import Control.Monad hiding(join)
import System.Directory
import System.FilePath((</>))
import System.Environment


deleteSvn ::  FilePath -> IO ()
deleteSvn dst = do
    dst_exist <- doesDirectoryExist dst
    if dst_exist
        --then putStrLn $ dst ++ " exist, delete .svn in this folder"
        then return ()
        else putStrLn "error"
    content <- getDirectoryContents dst
    let xs = filter (`notElem` [".", ".."]) content
    forM_ xs $ \name -> do
        let dstPath = dst </> name
        --putStrLn dstPath
        isDirectory <- doesDirectoryExist dstPath
        when isDirectory (
                if name == ".svn"
                        then do
                        putStrLn $ "remove a .svn folder:" ++ dstPath
                        removeDirectoryRecursive dstPath
                        else do
                        deleteSvn dstPath
            )

main::IO()
--main = getCurrentDirectory >>= deleteSvn 
main = do
    args <- getArgs
    if null args
        then do
        putStrLn "usage: deleteSVN path"
        else do
        deleteSvn $ args !! 0
