#include <stdio.h>
#include <stdarg.h>

#include <stdint.h>

#include <malloc.h> //malloc free ...
#include <string.h> //strlen

#define _snprintf snprintf_hook

/**
 * 性质:pure
 * 替换字符串函数内部使用的专用函数,替换目标字符串中识别出的模式为预设内容
 * %I64d -> %ld
 */
static
void str_process(const char * src, char * dst){
    while (*src != '\0')
    {
        switch (*src)
        {
        case '%':
            *dst++ = *src++;
            if (*src == 'I' && *(src + 1) == '6' && *(src + 2) == '4'
                && *(src + 3) == 'd')
            {
                *dst++ = 'l';
                *dst++ = 'd';
                src += 4;
            }
            break;
        default:
            *dst++ = *src++;
            break;
        }
    }
}

/**
 * 功能:
 * 实现函数
 * int snprintf(char *str, size_t size, const char *format, ...);
 * 中的格式化字符串转换,目前支持:
 * %I64d -> %ld
 *
 * 要求:
 * format为有效的格式化字符串,不能为null
 */
int snprintf_hook(char *str, size_t size, const char *format, ...)
{
    int r;
    size_t fslen = strlen(format);
    char * real_fs = malloc(fslen + 1);

    if (real_fs == NULL)
        return -1; //原函数要求失败返回negative value

    str_process(format, real_fs);
    va_list ap;
    va_start(ap, format);
    r = vsnprintf(str, size, real_fs, ap);
    va_end(ap);
    free(real_fs);
    return r;
}
/**
 * 功能:
 * 实现函数
 * int sprintf(char *str, const char *format, ...);
 * 中的格式化字符串转换,目前支持:
 * %I64d -> %ld
 *
 * 要求:
 * format为有效的格式化字符串,不能为null
*/
int sprintf_hook(char *str, const char *format, ...){
    int r;
    size_t fslen = strlen(format);
    char * real_fs = malloc(fslen + 1);

    if (real_fs == NULL)
        return -1; //原函数也要求失败返回negative value ;-)

    str_process(format, real_fs);
    va_list ap;
    va_start(ap, format);
    r = vsprintf(str, real_fs, ap);
    va_end(ap);
    free(real_fs);
    return r;
}

void test(void)
{
    char str_buf[128];
    snprintf(str_buf, 128, "int %d, long int %ld, char %c\n", 23, 214748364922L,
        'L');
    puts(str_buf);
    snprintf_hook(str_buf, 128, "int %d, long int %I64d, char %c\n", 23,
        214748364922L, 'L');
    puts(str_buf);
    sprintf_hook(str_buf, "%%%I64d,%s.", 1234567890123456L,"S.H.E");
    puts(str_buf);
}

int main(int argc, char const *argv[])
{
    test();
    return 0;
}
