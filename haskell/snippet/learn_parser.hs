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
