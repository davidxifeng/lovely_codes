#include <stdio.h>

int main(void) {
    const char * s = "love = -d david\nlove you";
    puts(s);
    char a[64], b[64];
    //sscanf(s, "%s = %[^\t\n]", a, b);
    sscanf(s, "%s = %[^\n]", a, b);
    puts(a);
    puts(b);
    return 0;
}

