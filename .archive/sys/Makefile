
FD_IMG = fd.img
# create image with `bximage`

all: run

.PHONY: run

run: boot.bin
	bochs -q -f bochsrc -rc dbg_cmd

boot.bin: boot.asm
	nasm -o $@ $^
	dd if=$@ of=$(FD_IMG) bs=512 count=1 conv=notrunc
