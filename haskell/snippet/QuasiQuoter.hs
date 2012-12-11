{-# LANGUAGE TemplateHaskell #-}
import Language.Haskell.TH.Quote
import Language.Haskell.TH

sillyOne :: QuasiQuoter
sillyOne = QuasiQuoter { quoteExp = \_ -> [| "yeah !" |] }
