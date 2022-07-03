module Eval (Token(..), Expression, eval, eval2)
where

import Text.Parsec ( parse, many, many1, spaces
                   , digit, char, eof, (<|>)
                   , choice, try, chainl1
                   )

import Text.Parsec.String (Parser)
-- Tue Apr  9 17:59:02 CST 2013 进行优先级比较的表达式求值函数
-- Fri May 24 14:02:35 CST 2013 学习了Parsec库的使用,写了一个简单的解析器

-- possibleSpace :: Parser ()
-- possibleSpace = skipMany (satisfy isSpace)
-- 库已经定义了spaces

data Token = Plus | Minus | Times | Divided_By | Power | Number !Double
     deriving (Show,Eq)

type Expression = [Token]

-- 解析2.3 或者2 这样简单的带小数点的数字
parse_number :: Parser Token
parse_number =
        try (do
            ds <- many1 digit
            _ <- char '.'
            f <- many1 digit
            spaces
            return $ Number (read (ds ++ '.' : f) :: Double)
        )
        <|>
        do  ds <- many1 digit
            spaces
            return $ Number (read ds :: Double)

op_expr :: Parser Token
op_expr =
        choice (map (\(o,t)-> char o >> spaces >> return t)
                    (zip "+-*/^" [Plus, Minus, Times, Divided_By, Power]))

number_op :: Parser [Token]
number_op =
        try (do
            n <- parse_number
            o <- op_expr
            return [n,o]
        )

exprs :: Parser [Token]
exprs = do
        spaces
        r <- many number_op
        l <- parse_number
        eof
        return $ concat r ++ [l]

op_bp :: Token -> Int
op_bp op
    | op `elem` [Plus, Minus]       = 1
    | op `elem` [Times, Divided_By] = 2
    | op == Power                   = 3
    | otherwise                     = error "error input"

eval' :: Expression -> Expression
eval' [] = [Number 0]
eval' [c] = [c]
eval' [_,_] = error "error input"
eval' xs@[x,op,y]
    | op `elem` [Plus, Minus] = xs
    | op `elem` [Times, Divided_By, Power] = [cal op x y]

eval' [_,_,_,_] = undefined
eval' (x:op:y:next_op:z:cs) =
        if op_bp op >= op_bp next_op
            then eval' $ (cal op x y) : next_op: z : cs
            else eval' (x : op: (eval' $ y:next_op:z : cs))

cal :: Token -> Token -> Token -> Token
cal op (Number x) (Number y) =
        case op of
            Plus       -> Number $ x + y
            Minus      -> Number $ x - y
            Times      -> Number $ x * y
            Divided_By -> Number $ x / y
            Power      -> Number $ x ** y
            _ -> undefined
cal _ _ _ = undefined

cal' :: Expression -> Token
cal' [x, op, y] = cal op x y
cal' [x] = x
cal' [] = error "empty list"
cal' [_, _] = error "empty list"
cal' (_:a:b:c) = cal' (a:b:c)

eval :: String -> Double
eval s =
        let
            Number r = either (const $ Number 0) (cal' . eval')
                (parse exprs "Expression Parser 0.1" s)
        in
            r

test :: Double
test = eval "12.5 + 2 *3 /4 +5^2 "

test' :: Double
test' = 12.5 + 2 *3 /4 +5**2

-- | 使用@chainl1@ 来直接在解析的时候求值,这个函数很给力
eval2 :: String -> Integer
eval2 s = either (const 2013521) id (parse eval2' "" s)

eval2' :: Parser Integer
eval2' = chainl1 (chainl1 (chainl1 number op0) op1) op2

number :: Parser Integer
number = do
        n <- many1 digit
        return (read n :: Integer)

-- | 几乎没有印象^是整数的power, **是浮点数的power了...
op0 :: Parser (Integer -> Integer -> Integer)
op0 = char '^' >> return (^)

op1 :: Parser (Integer -> Integer -> Integer)
op1 = (char '*' >> return (*)) <|> (char '/' >> return div)

op2 :: Parser (Integer -> Integer -> Integer)
op2 =
        (char '+' >> return (+))
        <|>
        (char '-' >> return (-))
