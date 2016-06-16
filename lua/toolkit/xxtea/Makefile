
.PHONY: clean all


CFLAGS = -std=gnu++0x -fPIC -O2 -pedantic
CFLAGS += -Wextra #all

ifdef LUAPATH
	CFLAGS += -I$(LUAPATH)
endif

all: xxtea.so blowfish.so

xxtea.so: xxtea.cpp xxtea.h
	gcc -shared -o $@ $(CFLAGS) $< -lstdc++

blowfish.so: blowfish.cpp blowfish.h
	gcc -shared -o $@ $(CFLAGS) $< -lstdc++

clean:
	$(RM) xxtea.so blowfish.so
