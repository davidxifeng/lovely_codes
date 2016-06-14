
.PHONY: clean all


CFLAGS = -fPIC -O2 -pedantic
CFLAGS += -Wextra #all

ifdef LUAPATH
	CFLAGS += -I$(LUAPATH)
endif

all: xxtea.so

xxtea.so: xxtea.cpp xxtea.h
	gcc -shared -o $@ $(CFLAGS) $< -lstdc++

clean:
	$(RM) xxtea.so
