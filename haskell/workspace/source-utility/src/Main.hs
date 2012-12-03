module Main where

import Text.XML.HXT.Core
import Data.Char
import System.Process


-- |use this function to learn hxt
test :: ArrowXml a => a XmlTree XmlTree
test = mkelem "hello" [sattr "description" "this is root elemment"]
        [ mkelem "world" [] [ txt "love haskell"]
          ,
          mkelem "test" [sattr "name" "second sibling"] [ mkelem "sub" [] [txt "sub text"]]
          ,
          eelem "love"
            += sattr "name" ( map toUpper "love")
            += txt "hello txt 1"
          ,
          eelem "love"
            += sattr "name" "2"
            += txt "hello txt 2"
          ,
          eelem "love"
            += sattr "name" "3"
            += txt "love 3"
        ]
    
{-
    runX :: IOSArrow XmlTree c -> IO [c]
            
    getText :: ArrowXml a => a XmlTree String            
-}

modifyXml :: FilePath -> IOSArrow XmlTree String
modifyXml rf =
    readDocument [withValidate no, withTrace 1] rf >>>
    getChildren >>> removeAllWhiteSpace >>>
    multi isElem >>> getName

processor :: FilePath -> IOSArrow XmlTree String
processor filename =
    readDocument [withValidate no, withTrace 1] filename >>>
    getChildren >>>
    hasName "hello" //> hasName "world" >>>
    getChildren >>>
    getText
       
processor2 :: FilePath -> IOSArrow XmlTree String
processor2 filename =
    readDocument [withValidate no, withTrace 1] filename >>>
    getChildren >>>
    deep (isElem >>> hasName "love") >>>
    getChildren >>>
    getText
    

play :: FilePath -> IO()
play arg = do 
         result <- runX (processor arg)
         print result
         r2 <- runX (processor2 arg)
         print r2
         r3 <- runX (modifyXml arg)
         print r3
         text_list <- runX
            (
            readDocument [withValidate no, withTrace 1] "hello.xml" >>>
            getChildren >>> isElem >>> removeAllWhiteSpace >>> 
            deep (
                    isText
                    <+>
                    (
                        isElem >>>
                        hasName "test" >>>
                        getAttrValue "name" >>>
                        mkText
                    )
                    <+>
                    (
                        isElem >>>
                        hasName "love" >>>
                        getAttrValue "name" >>>
                        mkText
                    )
                 )
            >>> getText >>> arr (map toUpper)
            )
         print text_list
         s <- runX (
                readDocument [withValidate no, withTrace 1] "test.xml"
                >>>
                processTopDown
                (
                    replaceChildren (mkelem "david" [] [txt "me"])
                    `when`
                    (isElem >>> hasName "test")
                )
                >>>
                --processTopDown
                processBottomUp
                (
                    replaceChildren (mkelem "david" [] [txt "me"])
                )
                >>>
                writeDocument [withIndent yes] "out.xml"
                >>>
                arr (\_ -> "hello")
              )
         putStrLn $ head s
         return ()
             
    
testmain :: IO ()
testmain = do
    _ <- runX(
            root [] [test]
            >>>
            writeDocument [withIndent yes] "hello.xml"
            )
    play "hello.xml"
    return ()

main :: IO ()
main
    = do        
        putStrLn "end"
        _ <- createProcess (shell "ls")
        _ <- createProcess (proc "dir" [])
        return ()