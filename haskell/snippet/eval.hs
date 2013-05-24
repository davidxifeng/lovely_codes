module Eval (Token(..), Expression, eval)
where

import Data.Char ( isSpace
                 , isDigit
                 )

import Text.Parsec ( ParseError, parse, many, many1, spaces
                   , digit, char, eof, (<|>), satisfy
                   , choice, try
                   )

import Text.Parsec.String (Parser)
import Text.Parsec.Token (float)
-- Tue Apr  9 17:59:02 CST 2013 进行优先级比较的表达式求值函数
-- Fri May 24 14:02:35 CST 2013 学习了Parsec库的使用,写了一个简单的解析器

-- possibleSpace :: Parser ()
-- possibleSpace = skipMany (satisfy isSpace)
-- 库已经定义了spaces

data Token = Plus | Minus | Times | Divided_By | Power | Number !Double
     deriving Show

type Expression = [Token]

-- 解析2.3 或者2 这样简单的带小数点的数字
parse_double :: Parser Token
parse_double =
        try (do
            ds <- many1 digit
            char '.'
            f <- many1 digit
            spaces
            return $ Number (read (ds ++ '.' : f) :: Double)
        )
        <|>
        (do
            ds <- many1 digit
            spaces
            return $ Number (read ds :: Double)
        )

expr :: Parser Token
expr =
        choice (map
               (\(o,t)-> char o >> spaces >> return t)
               (zip "+-*/^" [Plus, Minus, Times, Divided_By, Power]))
        <|>
        parse_double

exprs :: Parser [Token]
exprs = do
        r <- many expr
        eof
        return r

op_bp :: Token -> Int
op_bp op =
        case op of
            Plus       -> 1
            Minus      -> 1
            Times      -> 2
            Divided_By -> 2
            Power      -> 3
            otherwise  -> error "error input"

eval' :: Expression -> Expression
eval' [] = []
eval' (c:[]) = [c]
eval' (x:op:y:[]) =
        case op of
            Plus       -> x:op:y:[]
            Minus      -> x:op:y:[]
            Times      -> [cal op x y]
            Divided_By -> [cal op x y]
            Power      -> [cal op x y]

eval' (x:op:y:next_op:z:cs) =
        if (op_bp op) >= (op_bp next_op)
            then eval' $ (cal op x y) : next_op: z : cs
            else eval' (x : op: (eval' $ y:next_op:z : cs))

cal' :: Expression -> Token
cal' (x:op:y:[]) = cal op x y
cal' (x:[]) = x

cal :: Token -> Token -> Token -> Token
cal op (Number x) (Number y) =
        case op of
            Plus       -> Number $ x + y
            Minus      -> Number $ x - y
            Times      -> Number $ x * y
            Divided_By -> Number $ x / y
            Power      -> Number $ x ** y

eval :: String -> Double
eval s =
        let
            Number r = either (\_ -> Number 0) (cal' . eval')
                (parse exprs "Expression Parser 0.1" s)
        in
            r

test = eval "12.5 + 2 *3 /4 +5^2 "
test' = 12.5 + 2 *3 /4 +5**2
