#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int main(int argc, char * argv[]) {
    puts("this is a test");

    srand(time(NULL));

    int r = rand();
    if( r % 2 == 0) {
        puts(";-)\nreturn 1");
        return 1;
    }
    else {
        puts(";-D\nreturn 0");
        return 0;
    }
}
