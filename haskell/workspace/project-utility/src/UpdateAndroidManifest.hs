module UpdateAndroidManifest
    (addServiceInfo)
where

import System.Directory
import Text.XML.HXT.Core
import qualified Control.Monad as CM
import Control.Applicative((<$>))


whenM :: Monad m => m Bool -> m () -> m ()
--whenM :: IO Bool -> IO () -> IO ()
whenM s r = s >>= flip CM.when r

-- | all process assume that only have one level application...2012-09-26

-- | process manifest xml
addServiceInfo :: FilePath -> IO()
addServiceInfo file_name = do
    putStrLn $ "add services to xml file\n" ++ file_name
    let file_name_tmp = (++) file_name ".org.xml"
    -- when first run this tool, backup the orginal manifest file,
    -- then ...
    whenM (not <$> doesFileExist file_name_tmp)
        (putStrLn "tmp not exist" >> renameFile file_name file_name_tmp)
    _ <- runX (
            readDocument
                [ withValidate no
                , withTrace 1
                , withShowHaskell yes
                , withShowTree yes
                ] ("file://" ++ file_name_tmp)
            >>>
            processChildren ( seqA 
                    [ addService
                    , addBootReceiver
                    , addAdActivity
                    ])
            >>>
            writeDocument [ withIndent yes
                , withTrace 1
                ] file_name
        )
    --mapM_ (\x -> print x >> putStrLn "") rc
    putStrLn "end of update manifest process"
        
    
addAdActivity :: ArrowXml a => a XmlTree XmlTree
addAdActivity =
    processTopDown (
        choiceA [ (isElem >>> hasName "application"):-> replaceChildren (getChildren <+> ta)
                , (isElem >>> hasName "manifest"):-> replaceChildren (getChildren <+> tb) 
                , this :-> this
            ]
        )
    where
        ta = constA "<meta-data android:value=\"SDK20111812070129bb9oj4n571faaka\"\
            \ android:name=\"ADVIEW_SDK_KEY\" />\
            \<activity android:name=\"cn.domob.android.ads.DomobActivity\" \
            \ android:theme =  \"@android:style/Theme.Translucent\" />" >>> xread
        tb = constA "<uses-permission android:name=\"android.permission.INTERNET\" />\
                \<uses-permission android:name=\"android.permission.ACCESS_NETWORK_STATE\" />\
                \<uses-permission android:name=\"android.permission.READ_PHONE_STATE\" />\
                \<uses-permission android:name=\"android.permission.ACCESS_COARSE_LOCATION\"/>\
                \<uses-permission android:name=\"android.permission.ACCESS_FINE_LOCATION\"/>\
                \<uses-permission android:name=\"android.permission.ACCESS_WIFI_STATE\" />\
                \<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />\
                \<uses-permission android:name=\"android.permission.READ_EXTERNAL_STORAGE\" />\
                \<uses-permission android:name=\"android.permission.MOUNT_UNMOUNT_FILESYSTEMS\"/>\
                \<uses-permission android:name=\"android.permission.SYSTEM_ALERT_WINDOW\"/>\
                \<uses-permission android:name=\"android.permission.INSTALL_PACKAGES\"/>\
                \<uses-permission android:name=\"android.permission.RECEIVE_BOOT_COMPLETED\" />" >>> xread



addBootReceiver :: ArrowXml a => a XmlTree XmlTree
addBootReceiver
    =   processTopDown (
            replaceChildren (
                getChildren <+> bootReceiverElem
            )
            `when`
            (isElem >>> hasName "application")
        )
        where
        bootReceiverElem =
            constA  "<receiver android:name=\"com.teamtop.tpplatform.TpBootReceiver\">\
                    \<intent-filter>\
                    \<action android:name=\"android.intent.action.BOOT_COMPLETED\" />\
                    \</intent-filter>\
                    \</receiver>"
            >>> xread

addService :: ArrowXml a => a XmlTree XmlTree
addService = processTopDown (
                replaceChildren (
                    getChildren <+> serviceElem
                    )
                `when`
                (isElem >>> hasName "application")
                )
            where
                serviceElem = mkelem "service"
                    [sattr "android:name" "com.teamtop.tpplatform.TpService",
                     sattr "android:process" ".TpPlatform" ]
                        [mkelem "intent-filter" []
                            [mkelem "action"
                            [sattr "android:name" "com.teamtop.tpplatform.tp_service"] []
                        ]
                    ]



{-
getDescendents :: ArrowXml a => [String] -> a XmlTree XmlTree
getDescendents =
    foldl1 (\ x y -> x >>> getChildren >>> y)
      .
      map (\ n -> isElem >>> hasName n)
-}