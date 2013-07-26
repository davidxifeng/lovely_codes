module AppConfig
    (Config
    , getConfig
    , generateConfigFile
    , srcBaseDir
    , dstBaseDir
    , srcPkgName
    , dstPkgName
    , subDirs
    )
    where

import Text.XML.HXT.Core

data Config = Config
    { srcBaseDir :: String
    , srcPkgName  :: String
    , dstBaseDir  :: String
    , dstPkgName  :: String
    , subDirs   :: [String]
    }
    deriving (Show, Eq)

instance XmlPickler Config where
    xpickle = xpConfig

xpConfig        :: PU Config
xpConfig
    = xpElem "config" $
      xpWrap ( \ ((sd, dd, sp, dp, sds)) -> Config sd dd sp dp sds
             , \ t -> (srcBaseDir t, dstBaseDir t, srcPkgName t, dstPkgName t, subDirs t)
             ) $
      xp5Tuple (xpElem "template_dir" xpText)
               (xpElem "template_package_name" xpText)
               (xpElem "game_project_dir" xpText)
               (xpElem "game_package_name" xpText)
               (xpElem "folders" $ xpList $ xpElem "folder" xpText)

generateConfigFile :: FilePath -> IO ()
generateConfigFile file
    = do
        _ <- runX (
            constA demoTemplate >>>
            xpickleDocument xpickle [withIndent yes]
                file
            )
        return ()
        where
        demoTemplate
            = Config "sdk template directory" "com.example.hellojni"
                "game project directory" "game.package.name" ["src", "res", "libs"]

getConfig :: FilePath -> IO (Maybe Config)
getConfig file = do
        cfg <- runX (
             xunpickleDocument xpConfig
                [withValidate no
                , withTrace 1
                , withRemoveWS yes
                , withPreserveComment no
                ]
                file
             )
        if null cfg
            then do
                putStrLn usageString
                generateConfigFile file
                return Nothing
            else do
                putStrLn "cfg read result is"
                print $ head cfg
                putStrLn "end of print cfg"
                return $ Just (head cfg)
    where
        usageString = unlines [ "读取xml配置数据失败,"
                              , "可能是没有配置文件或者数据格式不正确"
                              , "生成空的模板文件"
                              ]
