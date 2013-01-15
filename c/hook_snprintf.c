#include <stdio.h>
#include <stdarg.h>

#include <stdint.h>

#include <malloc.h> //malloc free ...
#include <string.h> //strlen


#define _snprintf snprintf_hook

// %I64d -> %ld
//int snprintf(char *str, size_t size, const char *format, ...);
/**
 * 要求format为有效的格式化字符串,不能为null
 */
int snprintf_hook(char *str, size_t size, const char *format, ...) {
    int r;
    size_t fslen = strlen(format);
    char * real_fs = malloc(fslen + 1);

    const char * p = format;
    char * dst_cur = real_fs;
    printf("input string is %s", format);
    while( *p != '\0') {
        switch (*p){
        case '%':
            *dst_cur++ = *p++;
            if(*p == 'I' && *(p + 1) == '6' && *(p + 2) == '4' && *(p + 3) == 'd'){
                *dst_cur++ = 'l';
                *dst_cur++ = 'd';
                p+= 4;
            }
            break;
        default:
            *dst_cur++ = *p++;
            break;
        }
    }
    printf("output string is %s", real_fs);
    va_list ap;
    va_start(ap, format);
    vsnprintf(str, size, real_fs, ap);
    va_end(ap);
    free(real_fs);
    return r;
}

void test(void){
    char str_buf[128];
    snprintf(str_buf, 128, "int %d, long int %ld, char %c\n", 23, 214748364922L,
            'L');
    puts(str_buf);
    snprintf_hook(str_buf, 128, "int %d, long int %I64d, char %c\n", 23, 214748364922L,
            'L');
    puts(str_buf);
}

int main(int argc, char const *argv[])
{
    test();
    return 0;
}
