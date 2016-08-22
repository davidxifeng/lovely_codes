
.PHONY: clean all


CPPFLAGS = -std=gnu++0x -fPIC -O2 -pedantic
CPPFLAGS += -Wextra

CFLAGS = -std=c99 -fPIC -O2# -pedantic
CFLAGS += -Wextra

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
	SHARED_LIB = -dynamiclib -Wl,-undefined,dynamic_lookup
else
	SHARED_LIB  = -shared
endif

ifdef LUAPATH
	CPPFLAGS += -I$(LUAPATH)
	CFLAGS += -I$(LUAPATH)
endif

all: xxtea.so blowfish.so zlib.so

xxtea.so: xxtea.cpp xxtea.h
	gcc $(SHARED_LIB) -o $@ $(CPPFLAGS) $< -lstdc++

blowfish.so: blowfish.cpp blowfish.h
	gcc $(SHARED_LIB) -o $@ $(CPPFLAGS) $< -lstdc++

zlib.so: lua_zlib.c
	gcc $(SHARED_LIB) -o $@ $(CFLAGS) $< -lz

clean:
	$(RM) xxtea.so blowfish.so zlib.so
