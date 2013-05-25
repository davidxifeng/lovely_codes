import Text.Parsec
import Text.Parsec.String (Parser)

number :: Parser Integer
number = do
        n <- many1 digit
        return (read n :: Integer)

plus :: Parser (Integer -> Integer -> Integer)
plus = (char '+' >> return (+)) <|> (char '-' >> return (-))

-- | 按照从左到右的顺序计算
testl = parseTest $ chainl1 number plus
-- | 按照从左到右的顺序计算
testr = parseTest $ chainr1 number plus

test = test' "1-2+3"

test' s = do
        testl s -- 2
        testr s -- -4 <= 1-(2+3)

parens' :: Parser ()
parens' = do{ char '('
            ; parens'
            ; char ')'
            ; parens'
            }
          <|> return ()

contens :: Parser [Char]
contens = (many $ noneOf "()")

-- (s(d(e)f))
-- (s(1)2(3(4))f)
remove_match_parens  :: Parser [Char]
remove_match_parens  =
        do { char '('
           ; c2 <- contens
           ; mp <- remove_match_parens
           ; c3 <- contens
           ; char ')'
           ; c4 <- contens
           ; z <- remove_match_parens
           ; return $ c2 ++ mp ++ c3 ++ c4 ++ z
           }
        <|> return []

rp = do
        c1 <- contens
        rest <- remove_match_parens
        return $ c1 ++ rest

rptest = do
        parseTest rp ""
        parseTest rp "ab"
        parseTest rp "(12)"
        parseTest rp "(1(d)(s(f)d)2)"
        parseTest rp "(1(2(3))) 4(5) (6(7))"
