module Main where

import System.Environment(getArgs)
import System.Directory(getCurrentDirectory, renameFile, removeFile)
-- import qualified Data.Encoding
import qualified Data.ByteString.Lazy as BSL
import qualified Codec.Text.IConv  as IConv

import AppConfig
import FileUtility (processDirectoryList, fileTypeFilter)


convertEncoding :: String -> String -> FilePath -> IO ()
convertEncoding fromEnc toEnc filepath = do
        putStrLn $ "process file " ++ filepath
        let tf = filepath ++ "david.temp"
        renameFile filepath tf
        rs <- BSL.readFile tf -- 不知道失败的情况下,open的handle会在何时被关闭,eof何时?
        let rc = IConv.convertStrictly fromEnc toEnc rs
        case rc of
                Left val -> do
                        BSL.writeFile filepath val
                        removeFile tf
                        putStrLn "convert success"
                Right ex -> do
                        putStrLn "convert failed, just keep it unchanged"
                        renameFile tf filepath
                        showErr ex
    where
        showErr ex =
                case ex of
                IConv.UnsuportedConversion fe te
                        -> putStrLn $ "cannot convert from string encoding "
                        ++ show fe ++ " to string encoding " ++ show te
                IConv.InvalidChar    inputPos
                        -> putStrLn $ "invalid input sequence at byte offset "
                        ++ show inputPos
                IConv.IncompleteChar inputPos
                        -> putStrLn $ "incomplete input sequence at byte offset "
                        ++ show inputPos
                IConv.UnexpectedError _
                        -> putStrLn "Codec.Text.IConv: unexpected error"


mainAction :: FilePath -> IO ()
mainAction f = do
        x <- getConfig f
        case x of
                Just cfg -> processDirectoryList (fileTypeFilter $ fileTypes cfg)
                                (convertEncoding (fromEncoding cfg) (toEncoding cfg))
                                $ dstDirs cfg
                Nothing -> return ()

currentAction :: FilePath -> IO ()
currentAction f =
        processDirectoryList
                (fileTypeFilter [".c", ".cpp", ".h", ".vcproj", ".txt"])
                (convertEncoding "GB18030" "UTF-8" ) [f]
main::IO()
main = do
        args <- getArgs
        if null args
                then getCurrentDirectory >>= currentAction
                else mainAction $ head args
