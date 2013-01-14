#include <stdio.h>
#include <stdarg.h>

#include <stdint.h>

#include <malloc.h> //malloc free ...
#include <string.h> //strlen


#define _snprintf snprintf_hook

//int snprintf(char *str, size_t size, const char *format, ...);
int snprintf_hook(char *str, size_t size, const char *format, ...) {
    int r;
    size_t fslen = strlen(format);
    char * real_fs = malloc(fslen + 1);
    //char *
    //1. copy the string
    strcpy(real_fs, format);
    //2. replace all the founded sub string
    //while()
    //3. do the actual job
    free(real_fs);
    return r;
}

void test(void){
    char str_buf[128];
    snprintf(str_buf, 128, "int %d, long int %ld, char %c\n", 23, 214748364922L,
            'L');
    puts(str_buf);
}

int main(int argc, char const *argv[])
{
    test();
    return 0;
}
