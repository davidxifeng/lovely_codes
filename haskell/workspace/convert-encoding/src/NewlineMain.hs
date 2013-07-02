module Main where

import System.Environment(getArgs)
import System.Directory(getCurrentDirectory, renameFile, removeFile)

import FileUtility (processDirectoryList, fileTypeFilter)


cvt :: String -> String
cvt [] = []
cvt ('\r' : '\n' : cs) = '\n' : (cvt cs)
cvt (c : cs) = c : (cvt cs)

convertNewLine :: FilePath -> IO ()
convertNewLine file = do
        putStrLn $ "process file " ++ file
        fs <- readFile file
        -- lazy IO
        let tmpfile = "/tmp/cvt_nl_david" 
        writeFile tmpfile (cvt fs)
        renameFile tmpfile file

targetFileExtensionList :: [String]
targetFileExtensionList = [".c", ".cpp", ".h", ".txt", ".lua", ".m", ".mm"]

action :: FilePath -> IO ()
action f =
        processDirectoryList
            (fileTypeFilter targetFileExtensionList)
            convertNewLine
            [f]

main::IO()
main = do
        args <- getArgs
        if null args
            then do
                putStrLn "usage: dir"
            else do
                action $ head args

