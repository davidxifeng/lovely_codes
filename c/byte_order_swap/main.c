#include <stdio.h>
#include <stdint.h>

#include <sys/time.h>


#define BSWAP_64(x)     (((uint64_t)(x) << 56) | \
                        (((uint64_t)(x) << 40) & 0xff000000000000ULL) | \
                        (((uint64_t)(x) << 24) & 0xff0000000000ULL) | \
                        (((uint64_t)(x) << 8)  & 0xff00000000ULL) | \
                        (((uint64_t)(x) >> 8)  & 0xff000000ULL) | \
                        (((uint64_t)(x) >> 24) & 0xff0000ULL) | \
                        (((uint64_t)(x) >> 40) & 0xff00ULL) | \
                        ((uint64_t)(x)  >> 56))


#define OP_COUNT (((uint32_t)-1) / 25)

// 测试位操作
void test_bo() {
    uint32_t count;

    count = OP_COUNT;

    uint64_t i = 0x123456789abcdeff;
    uint64_t r;

    while (count--) {
        r = BSWAP_64(i);
    }
    printf("result is %llu\n", r);
}

// 测试赋值
void test_mc() {
    uint64_t i = 0x123456789abcdeff;
    uint32_t count;
    uint64_t r;

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
    printf("result is %llu\n", r);
}

// 测试赋值2
void test_mc2() {
    uint64_t i = 0x123456789abcdeff;
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
    printf("result is %llu\n", r);
}



void measure_time(void (*func)(), const char * str) {
    printf("measure %s\n", str);
    struct timeval tm_before;
    gettimeofday(&tm_before, NULL);
    func();
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

    x.d = 1.0;
    printf("%f\n", x.d);

    printf("%02X %02X %02X %02X %02X %02X %02X %02X\n",
            x.c[0], x.c[1], x.c[2], x.c[3],
            x.c[4], x.c[5], x.c[6], x.c[7]);
}

int main(int argc, char const* argv[]) {
    union_test();
    measure_time(test_mc, "memory copy");
    measure_time(test_mc2, "memory copy 2");
    measure_time(test_bo, "bitwise operation");
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
 */
