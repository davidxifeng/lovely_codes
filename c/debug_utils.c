#include "debug_utils.h"

#include <time.h>
#include <stdio.h>
#include <stdarg.h>

void debug_output(const char * format, ...){
#if __GNUC__
    time_t now;
    time(&now);
    struct tm *ltime;
    ltime = localtime(&now);
    fprintf(stderr, "%04d-%02d-%02d %02d:%02d:%02d :-> ", ltime->tm_year + 1900,
        ltime->tm_mon, ltime->tm_mday, ltime->tm_hour, ltime->tm_min,
        ltime->tm_sec);
    va_list ap;
    va_start(ap, format);
    vfprintf(stderr, format, ap);
    va_end(ap);
    fputs("\n", stderr);
#endif
}

int main(void) {
    debug_output("test");
    debug_output("test %s", "jack");
    dbg("test %s", "jack");
    debug_output("test %s %X", "love", 252);
    return 0;
}
