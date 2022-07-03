#include <stdio.h>
#include <string.h>


int main(void) {
    char ss[] = "hello xor";
    char sd[10];
    char * pc = ss;
    int i;
    memcpy(&i, ss, 4);
    //memcpy(&i, NULL, 0); //okay
    //memcpy(&i, NULL, 4); //will crash, sf
    printf("i is %d\n", i);
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
