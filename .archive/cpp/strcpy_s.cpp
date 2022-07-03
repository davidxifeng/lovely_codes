#include <string.h>
#include <stdio.h>

#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;
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
    //test gdb's stl pretty print with gdb-python
    vector<int> vi;
    vi.push_back(1);
    vi.push_back(2);
    vi.push_back(3);
    cout<<vi[1]<<endl;
    map<int, string> is;
    is[1] = "hello";
    is[2] = "lily";
    is[3] = "david";
    cout<<is[2]<<endl;
    const char * test = "hello";
    cout<< test<<endl;
    return 0;
}

