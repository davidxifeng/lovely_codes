module Main where

import System.Environment(getArgs)
-- import qualified Data.Encoding
import qualified Data.ByteString.Lazy as BSL
import qualified Codec.Text.IConv as IConv

import AppConfig
import FileUtility (processDirectoryList, fileTypeFilter)

testIConv :: IO()
testIConv = do
        BSL.interact (IConv.convert "UTF-8" "GB18030")

convertEncoding :: String -> String -> FilePath -> IO ()
convertEncoding fromEnc toEnc filepath = do
        putStrLn $ "process file " ++ filepath
        rs <- BSL.readFile filepath
        BSL.writeFile (filepath ++ ".new.txt") $ IConv.convert fromEnc toEnc rs


-- [".c", ".cpp", ".h", ".vcproj", ".txt", ".sln"]

mainAction :: FilePath -> IO ()
mainAction f = do
        x <- getConfig f
        case x of
                Just cfg -> do
                        processDirectoryList (fileTypeFilter $ fileTypes cfg)
                                (convertEncoding (fromEncoding cfg) (toEncoding cfg))
                                $ dstDirs cfg
                Nothing -> do
                        return ()
        return ()

main::IO()
main = do
        args <- getArgs
        if (null args)
                then mainAction "cfgfile"
                else mainAction $ args !! 0
