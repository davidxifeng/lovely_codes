#include "debug_utils.h"

#include <time.h>
#include <stdio.h>
#include <stdarg.h>

void debug_output(const char * format, ...){
    //fputs("→_→\t :-> \t", stderr);
    fputs(":->\t", stderr);
    va_list ap;
    va_start(ap, format);
    vfprintf(stderr, format, ap);
    va_end(ap);
    fputs("\n:\t", stderr);

    time_t now;
    time(&now);
    //ctime返回的结果是日期字符串+一个new line符号
    fprintf(stderr, "%s", ctime(&now));
    fputs("\n", stderr);
}

int main(void) {
    dbg("long is %u, long long is %u", sizeof(long), sizeof(long long));
    return 0;
}
