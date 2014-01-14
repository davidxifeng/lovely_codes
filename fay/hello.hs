module Hello where

import FFI
import Prelude

alert :: String -> Fay ()
alert = ffi "alert(%1)"

setBodyHtml :: String -> Fay ()
setBodyHtml = ffi "document.body.innerHTML = %1"

addWindowEvent :: String -> Fay () -> Fay ()
addWindowEvent = ffi "window.addEventListener(%1, %2)"

main :: Fay ()
main = do
  putStrLn "Hello Console!"
  alert "Hello Alert!"
  addWindowEvent "load" $ do
    putStrLn "The document has loaded"
    setBodyHtml "Hello HTML!"
