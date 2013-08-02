//Created: Sat Aug  3 00:57:37 CST 2013
//author: davidxifeng@gmail.com
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int main(int argc, char ** argv) {
    const char * testData = "123, 200, 789, 521";
    //const char * testData = "123, 20000000000000000000000000000000000000000000456, 789, 521";
    char * endPos;
    long value;
    for(;;) {
        value = strtol(testData, &endPos, 10);
        if(errno == EINVAL || errno == ERANGE) {
            printf("error %s\n", strerror(errno));
            break;
        }
        printf("value is %ld\n", value);
        if(*endPos == '\0') {
            break;
        }
        testData = ++endPos;
    }
    return 0;
}


