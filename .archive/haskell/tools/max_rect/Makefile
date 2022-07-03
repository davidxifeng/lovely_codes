
buildDemo:
	@ghc -isrc src/Main.hs -o MaxRect cbits/MaxRectsBinPack.cpp -lstdc++

# usage:
#ghci MaxRect.hs -L. -lstdc++ MaxRectsBinPack.o
#或
#ghci MaxRect.hs -L. -lmax
buildMaxLib:
	@gcc -Wall -shared -fPIC cbits/MaxRectsBinPack.cpp -lstdc++ -o libmax.dylib
