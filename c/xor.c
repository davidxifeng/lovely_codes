#include <stdio.h>
#include <string.h>


int main(void) {
    char ss[] = "hello xor";
    char sd[10];
    char * pc = ss;
    int i;
    for(i = 0; i < strlen(ss); i++)
    {
        sd[i] = ss[i] ^ 'H';
    }
    sd[i] = 0;
    puts(sd);

    char sc[10];
    pc = sd;
    for(i = 0; i < strlen(ss); i++)
    {
        sc[i] = sd[i] ^ 'H';
    }
    sc[i] = 0;
    puts(sc);

    return 0;
}
