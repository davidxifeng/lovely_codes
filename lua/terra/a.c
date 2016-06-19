// gcc a.c test.o -lz

#include <stdio.h>

extern int test(int, char const **);

int main(int argc, char const* argv[])
{
  printf("hello terra\n");
  printf("argv[0] %s\n", *argv);
  test(argc, argv);
  return 0;
}
