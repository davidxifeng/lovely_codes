#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <sys/time.h>

#define BSWAP_32(x)     (((uint32_t)(x) << 24) | \
                        (((uint32_t)(x) <<  8)  & 0xff0000) | \
                        (((uint32_t)(x) >>  8)  & 0xff00) | \
                        ((uint32_t)(x)  >> 24))


#define BSWAP_64(x)     (((uint64_t)(x) << 56) | \
                        (((uint64_t)(x) << 40) & 0xff000000000000ULL) | \
                        (((uint64_t)(x) << 24) & 0xff0000000000ULL) | \
                        (((uint64_t)(x) << 8)  & 0xff00000000ULL) | \
                        (((uint64_t)(x) >> 8)  & 0xff000000ULL) | \
                        (((uint64_t)(x) >> 24) & 0xff0000ULL) | \
                        (((uint64_t)(x) >> 40) & 0xff00ULL) | \
                        ((uint64_t)(x)  >> 56))

#if 1
#define OP_COUNT 1
#else
#define OP_COUNT (((uint32_t)-1) / 2500)
#endif

// 测试位操作
void test_bo(uint64_t i) {
    uint64_t r;
    uint32_t count;
    count = OP_COUNT;
    while (count--) {
        r = BSWAP_64(i);
    }
    printf("bo result is %llu\n", r);
}

// 测试赋值
void test_mc(uint64_t i) {
    uint64_t r;

    uint32_t count;
    count = OP_COUNT;

    while (count--) {
        uint8_t * s = (uint8_t *)&i + 7;
        uint8_t * d = (uint8_t *)&r;
        *d++ = *s--;
        *d++ = *s--;
        *d++ = *s--;
        *d++ = *s--;
        *d++ = *s--;
        *d++ = *s--;
        *d++ = *s--;
        *d   = *s  ;

    }
    printf("mc result is %llu\n", r);
}

// 测试赋值2
void test_mc2(uint64_t i) {
    uint32_t count;
    uint64_t r;

    count = OP_COUNT;

    while (count--) {
        uint8_t * s = (uint8_t *)&i + 7;
        uint8_t * d = (uint8_t *)&r;
        int c = 8;
        while (c--) {
            *d++ = *s--;
        }
    }
    printf("mc2 result is %llu\n", r);
}



void measure_time(void (*func)(uint64_t), uint64_t i, const char * str) {
    printf("measure %s\n", str);
    struct timeval tm_before;
    gettimeofday(&tm_before, NULL);
    func(i);
    struct timeval tm_after;
    gettimeofday(&tm_after, NULL);
    time_t sec = tm_after.tv_sec - tm_before.tv_sec;
    suseconds_t mis = tm_after.tv_usec - tm_before.tv_usec;
    if (mis < 0) {
        mis = 1000000 + mis;
        sec--;
    }
    printf("time used: %lu %d\n", sec, mis);
    printf("end\n\n");
}

void union_test() {
    union {
        uint64_t ull;
        uint8_t c[8];
        double d;
    } x = { .ull = 0x123456789abcdef0 };

    printf("%02X %02X %02X %02X %02X %02X %02X %02X\n",
            x.c[0], x.c[1], x.c[2], x.c[3],
            x.c[4], x.c[5], x.c[6], x.c[7]);

    printf("%llu\n", x.ull);

    x.d = 1.2344999991522893623141499119810760021209716796875;
    printf("%02X %02X %02X %02X %02X %02X %02X %02X\n",
            x.c[0], x.c[1], x.c[2], x.c[3],
            x.c[4], x.c[5], x.c[6], x.c[7]);
    printf("%e\n", x.d);

    x.ull = 0x3FF3C08312345678;
    printf("%02X %02X %02X %02X %02X %02X %02X %02X\n",
            x.c[0], x.c[1], x.c[2], x.c[3],
            x.c[4], x.c[5], x.c[6], x.c[7]);
}

static void test_b32() {
    unsigned char * c;
    uint32_t x = 0x12345678;
    c = (unsigned char *)&x;
    printf("%02X %02X %02X %02X\n", c[0], c[1], c[2], c[3]);
    uint32_t y = BSWAP_32(x);
    c = (unsigned char *)&y;
    printf("%02X %02X %02X %02X\n", c[0], c[1], c[2], c[3]);

}

static void test_swap_double() {
    union {
        double d;
        uint64_t u;
    } ud = {
        .u = 0x7856341283C0F33F
    };
    double x = 1.2344999991522893623141499119810760021209716796875;
    ud.u = BSWAP_64(ud.u);
    double r = ud.d;
    if (r == x) {
        printf("%.64f\n", ud.d);
        printf("swap okay\n");
    } else {
        printf("swap failed\n");
        printf("%.64f\n", ud.d);
    }

    double td = 1.2344999991522893623141499119810760021209716796875;
    if (memcmp(&td, "\x78\x56\x34\x12\x83\xC0\xF3\x3F", 8) == 0) {
        printf("little endian double\n");
    } else if (memcmp(&td, "\x3F\xF3\xC0\x83\x12\x34\x56\x78", 8) == 0) {
        printf("big endian double\n");
    } else {
        printf("not support number format to dump!");
    }

}

int main(int argc, char const* argv[]) {
    test_swap_double();
    test_b32();
    union_test();
    uint64_t i = 0x123456789abcdeff;
    measure_time(test_mc, i, "memory copy");
    measure_time(test_mc2, i, "memory copy 2");
    measure_time(test_bo, i, "bitwise operation");
    return 0;
}

/*
 * run with:
 * gcc -O0 main.c
 * result:
 * a.out
 * measure memory copy
 * result is 18437381296131290130
 * time used: 2 482348
 * end
 *
 * measure memory copy 2
 * result is 18437381296131290130
 * time used: 3 277690
 * end
 *
 * measure bitwise operation
 * result is 18437381296131290130
 * time used: 0 561877
 * end
 *
 * 总结: 内存操作的方法比位操作的方法慢得多. 有点出乎位最初的意料...
 *
 * next: 研究一下-O0下, 反汇编的结果
 *
 * Sun 01:47 Apr 19 开启 -O3优化后, test_bo 和test_mc 都被识别成交换字节序并
 * 使用一条指令 bswapq 实现了, 但是test_mc2 没有被优化
 *
 *
 */
/*
_test_bo:
0000000100000a60	55              	pushq	%rbp
0000000100000a61	4889e5          	movq	%rsp, %rbp
0000000100000a64	4889f9          	movq	%rdi, %rcx
0000000100000a67	480fc9          	bswapq	%rcx
0000000100000a6a	488d3d4f040000  	leaq	0x44f(%rip), %rdi       ## literal pool for: "bo result is %llu\n"
0000000100000a71	31c0            	xorl	%eax, %eax
0000000100000a73	4889ce          	movq	%rcx, %rsi
0000000100000a76	5d              	popq	%rbp
0000000100000a77	e9fc030000      	jmp	0x100000e78             ## symbol stub for: _printf
0000000100000a7c	0f1f4000        	nopl	(%rax)
_test_mc:
0000000100000a80	55              	pushq	%rbp
0000000100000a81	4889e5          	movq	%rsp, %rbp
0000000100000a84	4889f9          	movq	%rdi, %rcx
0000000100000a87	480fc9          	bswapq	%rcx
0000000100000a8a	488d3d42040000  	leaq	0x442(%rip), %rdi       ## literal pool for: "mc result is %llu\n"
0000000100000a91	31c0            	xorl	%eax, %eax
0000000100000a93	4889ce          	movq	%rcx, %rsi
0000000100000a96	5d              	popq	%rbp
0000000100000a97	e9dc030000      	jmp	0x100000e78             ## symbol stub for: _printf
0000000100000a9c	0f1f4000        	nopl	(%rax)
_test_mc2:
0000000100000aa0	55              	pushq	%rbp
0000000100000aa1	4889e5          	movq	%rsp, %rbp
0000000100000aa4	4989f8          	movq	%rdi, %r8
0000000100000aa7	49c1e838        	shrq	$0x38, %r8
0000000100000aab	4989f9          	movq	%rdi, %r9
0000000100000aae	49c1e930        	shrq	$0x30, %r9
0000000100000ab2	4989fa          	movq	%rdi, %r10
0000000100000ab5	49c1ea28        	shrq	$0x28, %r10
0000000100000ab9	4989fb          	movq	%rdi, %r11
0000000100000abc	49c1eb20        	shrq	$0x20, %r11
0000000100000ac0	4889f8          	movq	%rdi, %rax
0000000100000ac3	48c1e818        	shrq	$0x18, %rax
0000000100000ac7	4889f9          	movq	%rdi, %rcx
0000000100000aca	48c1e910        	shrq	$0x10, %rcx
0000000100000ace	4889fa          	movq	%rdi, %rdx
0000000100000ad1	48c1ea08        	shrq	$0x8, %rdx
0000000100000ad5	be5d8fc2f5      	movl	$0xf5c28f5d, %esi       ## imm = 0xF5C28F5D
0000000100000ada	660f1f440000    	nopw	(%rax,%rax)
0000000100000ae0	448845f8        	movb	%r8b, -0x8(%rbp)
0000000100000ae4	44884df9        	movb	%r9b, -0x7(%rbp)
0000000100000ae8	448855fa        	movb	%r10b, -0x6(%rbp)
0000000100000aec	44885dfb        	movb	%r11b, -0x5(%rbp)
0000000100000af0	8845fc          	movb	%al, -0x4(%rbp)
0000000100000af3	884dfd          	movb	%cl, -0x3(%rbp)
0000000100000af6	8855fe          	movb	%dl, -0x2(%rbp)
0000000100000af9	40887dff        	movb	%dil, -0x1(%rbp)
0000000100000afd	ffc6            	incl	%esi
0000000100000aff	75df            	jne	0x100000ae0
0000000100000b01	488b75f8        	movq	-0x8(%rbp), %rsi
0000000100000b05	488d3dda030000  	leaq	0x3da(%rip), %rdi       ## literal pool for: "mc2 result is %llu\n"
0000000100000b0c	31c0            	xorl	%eax, %eax
0000000100000b0e	5d              	popq	%rbp
0000000100000b0f	e964030000      	jmp	0x100000e78             ## symbol stub for: _printf
0000000100000b14	6666662e0f1f840000000000	nopw	%cs:(%rax,%rax)
*/
