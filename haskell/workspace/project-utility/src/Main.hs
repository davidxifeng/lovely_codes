import System.Directory(
    createDirectory, doesFileExist
    , doesDirectoryExist, getDirectoryContents
    , removeFile, renameFile
    , removeDirectoryRecursive
    )
import System.FilePath((</>) , splitExtension)
import Control.Monad (liftM, filterM)
import Data.List (sort)
import Control.Applicative((<$>))

import FileUtility
import UpdateAndroidManifest
import AppConfig
import Strings (replace)


copyDirs :: Config -> IO ()
copyDirs ac = do
    putStrLn "copy files"
    whenM (not <$> doesDirectoryExist (dstBaseDir ac)) (createDirectory $ dstBaseDir ac)
    mapM_ (\x -> copyDir (srcBaseDir ac </> x) (dstBaseDir ac </> x) ) (subDirs ac)

-- use function to replace this poor method
processDirectoryFile :: Config -> [FilePath] -> FilePath -> IO ()
processDirectoryFile _ [] _ = return ()
processDirectoryFile ac (x:xs) path = do
        processOneFile x path
        processDirectoryFile ac xs path
        where 
        -- processOneFile :: FilePath -> FilePath-> IO ()
        processOneFile file dir = do
                        let raw_file_name = dir </> file
                        let temp_file_name = dir </> file ++ ".has"
                        renameFile raw_file_name temp_file_name
                        file_string <- readFile temp_file_name
                        writeFile raw_file_name
                            (replace (srcPkgName ac) (dstPkgName ac) file_string)
                        putStrLn $ "write the processed file to " ++ raw_file_name
                        removeFile temp_file_name
        
        
replacePkgName :: Config -> [FilePath] -> IO()
replacePkgName _ []
    = return ()
replacePkgName ac (src_dir:src_dirs)
    = do
        putStrLn $ "now processing " ++ src_dir
        java_files <- getJavaFile src_dir
        processDirectoryFile ac java_files src_dir
        subdir_list <- getValidSubDir src_dir
        replacePkgName ac subdir_list
        replacePkgName ac src_dirs
            where 
                -- getAllSubDirectory :: FilePath -> IO [FilePath]
                getValidSubDir dir
                    = do
                        dc <- getDirectoryContents dir
                        let tdc = filter (\x -> x `notElem` [".", "..", ".svn"]) dc
                        let full_dc = map (dir </>) tdc
                        filterM doesDirectoryExist full_dc 

                    -- getJavaFile :: FilePath -> IO [FilePath]
                getJavaFile dir = (sort . filter isSourceFile) `liftM` getDirectoryContents dir
                    where
                    isSourceFile filepath = (snd.splitExtension) filepath `elem` [".java", ".Java"]
      
test :: String      
test = "hi,utf-8;你好,hi"      
    
main::IO()
main = do
    putStrLn test
    putStrLn "Android AD SDK helper 0.1"
    let cfgFile = "config.xml"
    havecfg <- doesFileExist cfgFile
    if havecfg
        then do
            x <- getConfig cfgFile -- ac == appConfig
            case x of
                Just ac -> do
                    putStrLn "get cfg file success"
                    let abc = dstBaseDir ac </> "src\\com\\teamtop"
                    whenM (doesDirectoryExist abc)
                        (   putStrLn "remove existing src files"
                            >> removeDirectoryRecursive  abc
                        )
                    copyDirs ac
                    addServiceInfo $ dstBaseDir ac </> "AndroidManifest.xml"
                    replacePkgName ac [dstBaseDir ac </> "src\\com\\teamtop"]
                    putStrLn "update AndroidManifest.xml file"
                Nothing -> do
                    putStrLn "can not get a valid config"
                    return ()
            
        else do
            putStrLn "first run, generate empty config file"
            generateConfigFile cfgFile
