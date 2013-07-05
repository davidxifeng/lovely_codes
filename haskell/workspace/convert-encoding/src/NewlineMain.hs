module Main where

import System.Environment(getArgs)
import System.Directory(getCurrentDirectory, renameFile, removeFile,
                       Permissions(..), getPermissions, setPermissions)

import FileUtility (processDirectoryList, fileTypeFilter)

import System.Cmd

cvt :: String -> String
cvt [] = []
cvt ('\r' : '\n' : cs) = '\n' : (cvt cs)
cvt (c : cs) = c : (cvt cs)

removeExe :: FilePath -> IO ()
removeExe file = do
        putStrLn $ "remove x file " ++ file
        --p <- getPermissions file
        --setPermissions file (p {executable = False})
        system $ "chmod -x " ++ file
        return ()


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
            --convertNewLine
            removeExe
            [f]

main::IO()
main = do
        args <- getArgs
        if null args
            then do
                putStrLn "usage: dir"
            else do
                action $ head args

