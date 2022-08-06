#include <stdio.h>
// 使用-Og 选项编译

// mult2:
//        movq    %rdi, %rax
//        imulq   %rsi, %rax
//        ret
long mult2(long a, long b) {
    long s = a * b;
    return s;
}

/*


mult_store:
        pushq   %rbx
        movq    %rdx, %rbx
        call    mult2
        movq    %rax, (%rbx)
        popq    %rbx
        ret
*/
void mult_store(long x, long y, long *dest) {
    // 开启O3优化的情况下,下面的调用会直接内联.
    long t = mult2(x, y);
    *dest = t;
}

//globalv:
//        .quad   2
long int globalv = 2;


// 栈寄存器-24, 分配栈空间
int main(int argc, char **argv) {
    long d; // 8(%rsp)
    // 
    mult_store(2, 3, &d); // leq指令加载有效地址,保存到rdx,第三个参数寄存器
			  // 然后是两个立即数mov到第二 第一个参数寄存器
			  // call
    // 先设置第二个参数rsi,然后是第一个参数edi
    printf("2 * 3 -> %ld\n", d);

    return 0;
}

/*
.LC0:
        .string "2 * 3 -> %ld\n"
main:
        subq    $24, %rsp
        leaq    8(%rsp), %rdx
        movl    $3, %esi
        movl    $2, %edi
        call    mult_store
        movq    8(%rsp), %rsi
        movl    $.LC0, %edi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        addq    $24, %rsp
        ret
*/
