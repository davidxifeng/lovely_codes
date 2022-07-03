#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

void print_ints(uint64_t * il) {
    uint32_t n = *(uint32_t*)il;
    il++;
    for (uint32_t i = 0; i < n; i++) {
        printf("%llu\n", *il++);
    }
}

// create int array from string
uint64_t * str2int(const char * input_str) {
    assert(input_str);
    size_t str_len = strlen(input_str);
    size_t n       = (str_len + 7) / 8;
    uint64_t * p   = malloc(sizeof(uint64_t) * (n + 1));

    // file meta info
    uint32_t * pi = (uint32_t *)p;
    *pi++ = (uint32_t)n;
    *pi = (uint32_t)str_len;

    uint64_t ta[2];

    uint64_t t = 1;
    if (*(char*)&t == '\x01') {
        ta[0] = 2405310850180214901;
    } else {
        ta[0] = 8462371930746478881;
    }
    ta[1] = ta[0] * 5201314 + 1;


    // generate int by input string
    size_t count = n >> 1; // n `quot` 2
    ++p; // skip header
    strncpy((char*)p, input_str, str_len);
    while (count--) {
        *p = *p ^ ta[0]; ++p;
        *p = *p ^ ta[1]; ++p;
    }
    if (n & 1) { // n % 2 == 1
        *p = *p ^ ta[0]; // 处理剩下的最后一个
        ++p;
    }

    return p - n - 1;
}

// in place
char * int2str(uint64_t * input, size_t * str_len) {
    assert(input);
    size_t n = (size_t)(*(uint32_t *)input);
    *str_len = (size_t)*((uint32_t *)input + 1);

    uint64_t ta[2];

    uint64_t t = 1;
    if (*(char*)&t == '\x01') {
        ta[0] = 2405310850180214901;
    } else {
        ta[0] = 8462371930746478881;
    }
    ta[1] = ta[0] * 5201314 + 1;

    char * r = (char *)(input + 1);

    size_t count = n >> 1;
    ++input;
    while (count--) {
        *input = *input ^ ta[0]; ++input;
        *input = *input ^ ta[1]; ++input;
    }
    if (n & 1) {
        *input = *input ^ ta[0];
    }

    return r;
}

void dispose_ints(uint64_t * is) {
    free(is);
}

void dump_word64_as_string(uint64_t d) {
    printf("%llu is:", d);
    const char * p = (const char *)&d;
    for (int i = 0; i < 8; i++) {
        printf("%c", *p++);
    }
    printf("\n");
}

void dump_memory(char * s, size_t len) {
    assert(len > 0);
    while (len--) {
        printf("%0X ", *s++);
    }
    printf("\n");
}

int main(int argc, char const* argv[]) {

    const char * ts = "12345678901";
    uint64_t * r = str2int(ts);
    print_ints(r);
    size_t n;
    dump_memory((char *)(r + 1), strlen(ts));
    char * s = int2str(r, &n);
    printf("len %lu\n", n);
    dump_memory(s, n);
    dump_memory(s, strlen(ts));
    dispose_ints(r);

    return 0;
}
