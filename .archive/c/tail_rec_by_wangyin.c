#include <stdio.h>

/* this programm is used to test gcc's tail recurse call optimise
 * 
 * run this code with gcc -O1: okay
 * without it: segmentation fault
 *
 * */

int recurse(int n) {
    printf("%i\n", n);
    return recurse(n+1000);
}

int main() {
    return recurse(1);
}

