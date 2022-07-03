module Test where

import System.Environment(getArgs)
import System.Directory(renameFile, removeFile)
import qualified Data.ByteString.Lazy as BSL
import qualified Codec.Text.IConv as IConv
import Prelude hiding(catch)
import Control.Exception (catch, SomeException)


convertEncoding :: String -> String -> FilePath -> IO ()
convertEncoding fromEnc toEnc filepath = do
        putStrLn $ "process file " ++ filepath
        let tf = filepath ++ "david.temp"
        renameFile filepath tf
        rs <- BSL.readFile tf
        let ns = IConv.convert fromEnc toEnc rs
        (do
                BSL.writeFile filepath ns
                removeFile tf
                )
                `catch` myhandler
        -- removeFile tf
        where
        myhandler :: SomeException -> IO ()
        myhandler ex = do
                putStrLn $ "exception catched" ++ show ex
                return ()

test :: FilePath -> IO ()
test f = do
        convertEncoding "GB18030" "UTF-8" f

main :: IO ()
main = do
        test "a"
        -- args <- getArgs
        -- test args !! 0