#include <stdio.h>

//a portable way
#define eprintf(format, ...) fprintf(stderr, format, ##__VA_ARGS__)

int main(void){
    eprintf("hi\n");
    eprintf("hi %s\n", "jack");
    eprintf("hi %s %d %c %u\n", "jack", 2, 65, 23);
    return 0;
}
