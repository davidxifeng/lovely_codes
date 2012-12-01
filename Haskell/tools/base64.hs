import Data.ByteString as BS
import Data.ByteString.UTF8 as BS.Utf8
import Data.ByteString.Base64 as BS.B64

test = do
	let s = "你好世界,永生门,TopGame3"
	let bs = BS.Utf8.fromString s
	let new_bs = BS.B64.encode bs
	BS.writeFile "/home/david/base64" new_bs
