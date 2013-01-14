#include <time.h>
#include <stdio.h>

int main(int argc, char const *argv[])
{
    time_t now;
    time(&now);
    puts(ctime(&now));
    struct tm *ltime;
    //返回的指针指向一块静态分配的区域,后续的调用会重写此块内存
    ltime = localtime(&now);
    puts(asctime(ltime));
    return 0;
}
