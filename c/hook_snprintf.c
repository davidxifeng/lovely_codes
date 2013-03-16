#include <stdio.h>
#include <stdarg.h>

#include <stdint.h>

#include <malloc.h> //malloc free ...
#include <string.h> //strlen

#define _snprintf snprintf_hook
#define sprintf sprintf_hook

/**
 * 性质:pure
 * 替换字符串函数内部使用的专用函数,替换目标字符串中识别出的模式为预设内容
 * %I64d -> %ld
 * %I64u -> %lu
 * note: dst末尾的0
 */
static
void str_process(const char * src, char * dst){
    while (*src != '\0')
    {
        switch (*src)
        {
        case '%':
            *dst++ = *src++;
            if (*src == 'I' && *(src + 1) == '6' && *(src + 2) == '4')
            {
                if (*(src + 3) == 'd')
                {
                    *dst++ = 'l';
                    *dst++ = 'd';
                    src += 4;
                }
                else if(*(src + 3) == 'u')
                {
                    *dst++ = 'l';
                    *dst++ = 'u';
                    src += 4;
                }
            }
            break;
        default:
            *dst++ = *src++;
            break;
        }
    }
    *dst = '\0';//crashed here once; and use malloc/free too much may cause
    //performance issue
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
    char * real_fs = malloc(fslen + 1);//无需memset 0重量级操作,str_proc搞定\0

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
    char sql[256]={0};
    _snprintf(sql,256,"call arrangeArena(@ret)");
    puts(sql);

    memset(sql,0,256);
    _snprintf(sql,256,"select * from zbz_jjcrank");
    puts(sql);

    sprintf(sql, "hihihihi");
    puts(sql);
}

//void test_format_time(void);
void test_file(void);

int main(int argc, char const *argv[])
{
    //test();
    //test_format_time();
    test_file();
    return 0;
}
