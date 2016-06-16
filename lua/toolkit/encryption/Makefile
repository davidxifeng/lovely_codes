
.PHONY: clean all


CPPFLAGS = -std=gnu++0x -fPIC -O2 -pedantic
CPPFLAGS += -Wextra

CFLAGS = -std=c99 -fPIC -O2# -pedantic
CFLAGS += -Wextra

ifdef LUAPATH
	CPPFLAGS += -I$(LUAPATH)
	CFLAGS += -I$(LUAPATH)
endif

all: xxtea.so blowfish.so zlib.so

xxtea.so: xxtea.cpp xxtea.h
	gcc -shared -o $@ $(CPPFLAGS) $< -lstdc++

blowfish.so: blowfish.cpp blowfish.h
	gcc -shared -o $@ $(CPPFLAGS) $< -lstdc++

zlib.so: lua_zlib.c
	gcc -shared -o $@ $(CFLAGS) $< -lz

clean:
	$(RM) xxtea.so blowfish.so zlib.so
