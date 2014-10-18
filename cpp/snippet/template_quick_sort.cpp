#include<iostream>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
using namespace std;

///////////////////////////////////////////////////////
//QuickSort

template<class T>
void QuickSort(T v[],int s,int e)
{
    if( s >= e ) return ;
    int ts = s , te = e;
    T t = v[e];
    while( s < e )
    {
        while( v[s] <= t && s < e) s++;
        v[e] = v[s];

        while( v[e] >= t && s < e) e--;
        v[s] = v[e];
    }
    v[e] = t;

    QuickSort(v,ts,e-1);
    QuickSort(v,e+1,te);
}

///////////////////////////////////////////////////////////

#define len 1000000
int v[len];

int main()
{
    for(int i = 0; i < len; i++ ) v[i] = i;
    for(int i = 0; i < len; i++ ) v[i] = rand();
    QuickSort(v,0,len);
    for(int i=0;i<len;i++) printf("%d ",v[i]);
    printf("\n");
    return 0;
}
