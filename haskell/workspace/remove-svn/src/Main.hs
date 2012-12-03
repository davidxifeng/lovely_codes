module Main where
import Control.Monad hiding(join)
import System.Directory
import System.FilePath((</>))


deleteSvn ::  FilePath -> IO ()
deleteSvn dst = do
    dst_exist <- doesDirectoryExist dst
    if dst_exist
        then putStrLn $ dst ++ " exist, delete .svn in this folder"
        else putStrLn "error"
    content <- getDirectoryContents dst
    let xs = filter (`notElem` [".", ".."]) content
    forM_ xs $ \name -> do
        let dstPath = dst </> name
        putStrLn dstPath
        isDirectory <- doesDirectoryExist dstPath
        if isDirectory
            then do
                if name == ".svn"
                    then do
                        putStrLn $ "delete a svn folder" ++ dstPath
                        removeDirectoryRecursive dstPath
                    else deleteSvn dstPath
            else return ()
main::IO()
main = getCurrentDirectory >>= deleteSvn 