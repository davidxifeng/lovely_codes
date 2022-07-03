#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <errno.h>
#include <sys/mman.h>
#include <unistd.h> // for sysconf

/*
  compile with:
  gcc -Wl,-allow_stack_execute -m32 test.jit.c
*/

typedef int (*FuncPtr)();

int make_executable_memory(int page_num, void **addr) {
    size_t pagesize = sysconf(_SC_PAGESIZE);
    printf("current page size is %zu\n", pagesize);
    size_t mem_size = page_num * pagesize;
    *addr = (FuncPtr) malloc(mem_size);
    // 计算出 目标内存所在的页的起始地址
    void * page_begin = (void *)((uintptr_t)*addr & ~(pagesize - 1));
    int r = mprotect(page_begin, mem_size, PROT_EXEC | PROT_READ | PROT_WRITE);
    if (r != 0) {
      printf("mprotect call failed: %s\n", strerror(errno));
    }
    return r;
}

int main(int argc, char const* argv[])
{
    // Create a function:
    char testFunc[] = {
        0x90,                         // NOP (not really necessary...)
        0xB8, 0x10, 0x00, 0x00, 0x00, // MOVL $16,%eax
        0xC3 // RET
    };
    int result = (*(FuncPtr)testFunc)();
    printf("call stack: Result %d\n", result);

    FuncPtr testFuncPtr;
    int r = make_executable_memory(2, (void **)&testFuncPtr);
    if (r == 0) {
      memmove(testFuncPtr, testFunc, 7 );
      int result = (*testFuncPtr)();
      printf("call heap: Result %d\n", result);
    }

    return 0;
}
