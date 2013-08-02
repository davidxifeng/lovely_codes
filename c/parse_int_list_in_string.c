//Created: Sat Aug  3 00:57:37 CST 2013
//author: davidxifeng@gmail.com
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
    const char * testData = "123, 456, 789, 521";
    char * endPos;
    long value;
    do {
        value = strtol(testData, &endPos, 10);
        if(*endPos == '\0') {
            break;
        }
        testData = ++endPos;
        printf("value is %ld\n", value);
    }while(1);
    return 0;
}


