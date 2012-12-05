module Main where

import System.Environment(getArgs)
-- import qualified Data.Encoding
import qualified Data.ByteString.Lazy as BSL
import Data.Char (toLower)

import System.FilePath(splitExtension) 
import qualified Codec.Text.IConv as IConv

import AppConfig
import FileUtility (processDirectoryList)

testIConv :: IO()
testIConv = do
        BSL.interact (IConv.convert "UTF-8" "GB18030")

testAction :: FilePath -> IO ()
testAction filepath = do
        putStrLn $ "process file " ++ filepath
        rs <- BSL.readFile filepath
        BSL.writeFile (filepath ++ ".new.txt") $ IConv.convert "GB18030" "UTF-8" rs


fileFilter :: [String] -> FilePath -> Bool
fileFilter extlist file = map toLower (snd $ splitExtension file)
        `elem` extlist
-- [".c", ".cpp", ".h", ".vcproj", ".txt", ".sln"]

mainAction :: FilePath -> IO ()
mainAction f = do
        x <- getConfig f
        case x of
                Just cfg -> do
                        processDirectoryList (fileFilter $ fileTypes cfg)
                                testAction $ dstDirs cfg
                Nothing -> do
                        return ()
        return ()

main::IO()
main = do
        args <- getArgs
        if (null args)
                then mainAction "cfgfile"
                else mainAction $ args !! 0
