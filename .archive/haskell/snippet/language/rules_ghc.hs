{-# RULES
"reverse.reverse/id" reverse . reverse = id
  #-}
main = print . head . reverse . reverse $ [1..]

