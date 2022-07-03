import Codec.Archive.Zip
import System.IO
import qualified Data.ByteString.Lazy as B
import System.Exit
import System.Environment
import System.Directory
import System.Console.GetOpt
import Control.Monad ( when )
import Control.Applicative ( (<$>) )

main :: IO ()
main = do
        argv <- getArgs
        fla_zip_file <- return $ argv !! 0
        output_path <- return $ (take ((length fla_zip_file) - 4) fla_zip_file) ++ "/"
        exists <- doesFileExist fla_zip_file
        if exists
            then do
                archive <- toArchive <$> B.readFile fla_zip_file
                archive' <- return $ updateArchive output_path archive
                mapM_ (writeEntry [OptVerbose]) $ zEntries archive'
            else return ()

updateArchive :: FilePath -> Archive -> Archive
updateArchive output archive =
        archive {zEntries = updateZEntries (zEntries archive)}
    where
        updateZEntries :: [Entry] -> [Entry]
        updateZEntries [] = []
        updateZEntries (c:cs) = c{eRelativePath = ne (eRelativePath c)} : updateZEntries cs

        ne :: FilePath -> FilePath
        ne fp = output ++ fp
