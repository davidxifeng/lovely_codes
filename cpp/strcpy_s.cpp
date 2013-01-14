#include <string.h>
#include <stdio.h>

// note: g++ -lbsd
#include <bsd/string.h>

int strcpy_s(
        char * strDest,
        size_t numberOfElements,
        const char * strSrc
        );

int strcpy_s(char * strDest, size_t numberOfElements, const char * strSrc){
    return strlcpy(strDest, strSrc, numberOfElements);
}
template <size_t size>
int strcpy_s(char (&strDest)[size], const char * strSource);

template <size_t size>
int strcpy_s(char (&strDest)[size], const char * strSource){
    return strlcpy(strDest, strSource, size);
}

int david(int i, int j){
    return i+j;
}

#define david(a,b,c) love(a,b,c)
int love(int i, int j, int k){
    return i+j+k;
}

template <typename T, bool with_std_eq_cpp_0x = true>
//cpp: 你还觉得你不够复杂吗?新标准的默认模版参数...越来越不喜欢C++的设计了...
void SameNameTest(T a, int b, int c) {
    printf("%d,%d, %ld\n", b, c, a + b);
    if (with_std_eq_cpp_0x) {
        puts("bad cpp");
    }
}

int main(int argc, char ** argv){
    //char sd[10], bd[30];
    char sd[10];
    const char * sr = "hello";
    const char * br = "0123456789abcde";
    //strcpy(sd, br);
    printf("d is %d, l is %d\n", david(1,2, 0), david(1,2,3));
    SameNameTest(23L, 2, 3);
    strcpy_s(sd, 10, br);
    puts(sd);
    //strcpy_s(sd, br);
    //puts(sd);
    return 0;
}

