-- 进行优先级比较的表达式求值函数
-- Tue Apr  9 17:59:02 CST 2013


type Expression = [Token]

data Token = Plus | Minus | Times | Divided_By | Power | Number Double
     deriving Show

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

eval :: Expression -> Token
eval exp = cal' $ eval' exp

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

test = eval [Number 2, Plus , Number 3, Times , Number 4, Power, Number 2, Plus, Number 5, Times, Number 2]
