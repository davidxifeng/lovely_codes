#include <iostream>

using namespace std;

int count = 0;

void move(char x, int n, char z)
{
    count++;
    cout<<count<<" time move disk "<<n<<" from "<<x<<" to "<<z<<endl;
}

void hanoi(int n, char x, char y, char z)
{
    if(n == 1)
        move(x, 1, z);
    else
    {
        hanoi(n-1, x, z, y);
        move(x, n, z);
        hanoi(n-1, y, x, z);
    }
}

int main(void)
{
    cout<<"Hello Hanoi!"<<endl;
    int i;
    while(true)
    {
        cin>>i;
        if(i==0)
            break;
        count = 0;
        hanoi(i, 'a', 'b', 'c');
    }
    return 0;
}
//Feb/10 Fri 18:54:39 very easy to write.
//f 1 = 1 
//f n = 2*f(n-1)+1
//f n = 2^n -1
