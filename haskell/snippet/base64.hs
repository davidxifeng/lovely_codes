import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BS.Utf8
import qualified Data.ByteString.Base64 as BS.B64
{--
qualified: 不可以使用没有加限定符的名字;
as: 重命名;
hiding: 可以隐藏掉某个符号;
--}

test2 = do
	putStrLn "hello kitty"

test = do
	let s = "你好世界,永生门,TopGame3"
	let bs = BS.Utf8.fromString s
	let new_bs = BS.B64.encode bs
	BS.writeFile "/home/david/base64" new_bs
