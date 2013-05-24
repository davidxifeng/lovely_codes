-- file: ch16/csv1.hs
import Text.Parsec ( ParseError
                   , parse
                   , many
                   , noneOf
                   , try
                   , (<|>)
                   , (<?>)
                   , eof

                   , string
                   , char
                   , endBy
                   , sepBy
                   )

import Text.Parsec.String (GenParser, Parser)

{- A CSV file contains 0 or more lines, each of which is terminated
   by the end-of-line character (eol). -}
--csvFile :: GenParser Char st [[String]]
csvFile :: Parser [[String]]
csvFile =
    do result <- many line
       eof
       return result

-- Each line contains 1 or more cells, separated by a comma
--line :: GenParser Char st [String]
line :: Parser [String]
line =
    do result <- cells
       eol                       -- end of line
       return result

-- Build up a list of cells.  Try to parse the first cell, then figure out
-- what ends the cell.
cells :: GenParser Char st [String]
cells =
    do first <- cellContent
       next <- remainingCells
       return (first : next)

-- The cell either ends with a comma, indicating that 1 or more cells follow,
-- or it doesn't, indicating that we're at the end of the cells for this line
remainingCells :: GenParser Char st [String]
remainingCells =
    (char ',' >> cells)            -- Found comma?  More cells coming
    <|> (return [])                -- No comma?  Return [], no more cells

-- Each cell contains 0 or more characters, which must not be a comma or
-- EOL
cellContent :: GenParser Char st String
cellContent =
    many (noneOf ",\n")

-- The end of line character is \n
eol :: GenParser Char st Char
eol = char '\n'

parseCSV :: String -> Either ParseError [[String]]
parseCSV input = parse csvFile "(unknown)" input

test = parseCSV "love, you, david\nlove, me, grace\n\nhi\nhi,you\n"


csvFile' = endBy line' eol'
line' = sepBy cell' (char ',')
cell' = many (noneOf ",\r\n")
eol' =   string "\n"
    <|> string "\r"
    <|> try (string "\n\r")
    <|> try (string "\r\n")

parseCSV' :: String -> Either ParseError [[String]]
parseCSV' = parse csvFile' "(unknown)"

test' = parseCSV' "love, you, david\r\nlove, me, grace\n\nhi\nhi,you\n"


csvFile'' :: Parser [[String]]
csvFile'' = endBy line'' eol''
line'' :: Parser [String]
line'' = sepBy cell'' (char ',')
cell'' :: Parser String
cell'' = quotedCell <|> many (noneOf ",\n\r")

quotedCell :: Parser String
quotedCell =
    do char '"'
       content <- many quotedChar
       char '"' <?> "quote at end of cell"
       return content

quotedChar :: Parser Char
quotedChar =
        noneOf "\""
    <|> try (string "\"\"" >> return '"')

eol'' :: Parser String
eol'' =   try (string "\n\r")
    <|> try (string "\r\n")
    <|> string "\n"
    <|> string "\r"
    <?> "end of line"

test'' = parse csvFile'' "test" "\"love\"\" you\", david\r\nlove, me, grace\n\nhi\nhi,you\n"

