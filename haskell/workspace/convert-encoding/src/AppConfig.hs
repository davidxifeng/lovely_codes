
module AppConfig
        (Config(..), getConfig)
        where


import Text.XML.HXT.Core

data Config = Config 
    { dstDirs :: [String]
    , fromEncoding  :: String
    , toEncoding  :: String
    , fileTypes   :: [String]
    }
    deriving (Show)
    
instance XmlPickler Config where
        xpickle = xpConfig
    
xpConfig :: PU Config
xpConfig
        = xpElem "config" $
          xpWrap ( \ ((a, b, c, d)) -> Config a b c d,
                \ t -> (dstDirs t, fromEncoding t, toEncoding t, fileTypes t))
                $
          xp4Tuple (xpElem "目标目录列表" $ xpList $ xpElem "目录" xpText)
                   (xpElem "源编码" xpText)
                   (xpElem "目标编码" xpText)
                   (xpElem "过滤文件类型" $ xpList $ xpElem "类型名" xpText)

generateConfig :: FilePath -> IO ()
generateConfig file
        = do
                _ <- runX (constA demo >>> xpickleDocument xpickle [withIndent yes] file)
                return ()
                where
                demo = Config ["目录1", "目录2"]
                        "GB18030" "UTF-8"
                        [".c", ".cpp", ".h", ".vcproj", ".txt", ".sln"]

getConfig :: FilePath -> IO (Maybe Config)
getConfig file
        = do
                cfg <- runX (xunpickleDocument xpConfig
                        [withValidate no, withTrace 1, withRemoveWS yes]
                        file)
                if null cfg
                        then do
                                putStrLn "generate template config file"
                                generateConfig file
                                return Nothing
                        else do
                                return $ Just (head cfg)
