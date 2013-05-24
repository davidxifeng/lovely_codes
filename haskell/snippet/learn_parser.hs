import Text.Parsec
import Text.Parsec.String (Parser)

number :: Parser Integer
number = do
        n <- many1 digit
        return (read n :: Integer)

plus :: Parser (Integer -> Integer -> Integer)
plus =
        do
            char '+'
            return (+)
        <|>
        do
            char '-'
            return (-)

adds :: Parser Integer
adds = do
        chainl1 number plus

test = parseTest adds "1+2-3+4"
