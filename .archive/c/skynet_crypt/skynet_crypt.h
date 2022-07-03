#include <stdint.h>

uint64_t random_ulong(void);

// 要求uint64_t 是 小端字节序存储的
// 目标平台 arm x86 x86-64
// 符合此要求，所以不做字节序检查和转换的处理
// 当此代码需要在大端平台上运行的时候，再做转换

uint64_t dh_exchange(uint64_t x64);

uint64_t dh_secret(uint64_t x, uint64_t y);

size_t des_encode(uint8_t * text,
    size_t textsz,
    uint64_t key,
    uint8_t * buffer); // 要求buffer的size >= textsz + 8 (简化处理 最坏情况)

// 成功解密，返回0
// 失败，返回错误码 1,2,3
int des_decode(uint8_t * text,
    size_t textsz,
    uint64_t key,
    uint8_t * buffer,
    size_t * msg_sz);

void hash_key(const char * str, int sz, uint8_t key[8]);

uint64_t hmac64(uint64_t a, uint64_t b);
