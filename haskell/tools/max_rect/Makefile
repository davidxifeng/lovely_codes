
buildDemo:
	@ghc MaxRect.hs cbits/MaxRectsBinPack.cpp -lstdc++

# usage:
#ghci MaxRect.hs -L. -lstdc++ MaxRectsBinPack.o
#或
#ghci MaxRect.hs -L. -lstdc++ -lmax
buildMaxLib:
	@gcc -Wall -shared -fPIC cbits/MaxRectsBinPack.cpp -lstdc++ -o libmax.dylib
