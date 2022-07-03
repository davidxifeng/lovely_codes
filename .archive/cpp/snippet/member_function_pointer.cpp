#include <iostream>

using namespace std;

class A {
private:
    int i;
public:

    A(int i) {
        this->i = i;
    }

    void test1() {
        cout<<"member func 1 -> "<<i<<endl;
    }

    void test2() {
        cout<<"member func 2 -> "<<i<<endl;
    }
};

typedef void (A::*pTest)();

int main(int argc, char ** argv) {
    A a1(1), a2(2);
    pTest pt1;

    pt1 = &A::test1;
    (a1.*pt1)();
    pt1 = &A::test2;
    (a2.*pt1)();

    A * pa1 = &a1;

    (pa1 ->* pt1)();
    return 0;
}
