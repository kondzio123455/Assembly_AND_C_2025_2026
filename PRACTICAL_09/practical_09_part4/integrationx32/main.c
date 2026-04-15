#include <stdio.h>

extern int add(int a, int b, int c);

extern int sub(int a, int b);

int main(int argc, char **argv)

{
  int result1 = add(4, 6, 8);
  int result2 = sub(5, 7);

  printf("%d\n", result1);
  printf("%d\n", result2);
  return 0;
}


