import Data.Encoding
import Data.Encoding.ASCII
import Data.Encoding.UTF8
import Data.Encoding.UTF16
import Data.Encoding.UTF32
import Data.Encoding.GB18030

import Data.Binary
import Data.Binary.Put
import Data.Binary.Get

import Data.Word

import qualified Data.Text as T

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS.C8
import qualified Data.ByteString.UTF8 as BS.Utf8
import qualified Codec.Binary.UTF8.String as BS.Utf8


import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.Lazy.UTF8 as BSL.Utf8

testEncodePack = do
	let hs = "ABC,Love you你好,おはよう御座います！"
	let word8List = BS.Utf8.encode hs
	let bs = BS.pack word8List
	BS.putStr bs
	BS.writeFile "/tmp/bs2" bs

test :: Get (Word8, Word8)
test = do
	a <- getWord8
	b <- getWord8
	return (a, b)

testPut :: Put
testPut = do
	putWord8 255
	putWord16be 1
	putWord32le 8

main0 = do
	let f = "/home/david/test"
	byte_string <- readFile f
	return ()

main1 = do
	let s = "ABC abc 你好,世界, I love you"
	-- C8中的pack是把unicode中的32位的code point当作8位的来处理,只产生0~255的值
	let bs = BS.C8.pack s
	let f = "/home/david/test"
	BS.C8.writeFile f bs
	let f2 = "/home/david/test_utf8"
	let utf8_string_from_haskell_32_string = BSL.Utf8.fromString "abc, 你好世界, I love you"
	BSL.writeFile f2 utf8_string_from_haskell_32_string
	-- lazy byte string 可以转换成strict string chunks list, 然后再合并成strict byte string
	let f3 = "/home/david/test_utf8_strict_string"
	BS.writeFile f3 $ BS.concat $ BSL.toChunks utf8_string_from_haskell_32_string
	-- bsl模块也有一个自带的转换函数
	-- BS.writeFile f3 $ BSL.toStrict utf8_string_from_haskell_32_string
	-- 原来只有新版的bytestring库才有此函数
	return ()

main = do
	-- c <- BL.getContents
	-- print $ runGet test c
	BSL.putStr $ runPut testPut
	BSL.writeFile "/home/david/testme" $ BSL.Utf8.fromString "Hello,世界,Hello"
	writeFile "/home/david/test3" "Hello,世界,Hello"
	return ()


-- just okay! 
-- Sun Dec  2 02:17:41 CST 2012
testEnc = do
	BSL.writeFile "/home/david/gbcode1" $ encodeLazyByteString GB18030 "测试okay"
	BSL.writeFile "/home/david/gbcode2" $ encodeLazyByteString UTF32 "测试okay"
	BSL.writeFile "/home/david/gbcode3" $ encodeLazyByteString UTF16 "测试okay"
	return ()
