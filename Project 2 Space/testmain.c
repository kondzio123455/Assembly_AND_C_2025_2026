/*
 * file: testmain.c
 * author: konrad skoczylas c00309030
 * description: unit tests for the assembly logic.
 */

#include <stdio.h>                                              // standard input output
#include <assert.h>                                             // testing assertions library

extern long register_adder(long a, long b);                     // link our assembly math module

int main() {
    printf("--- Running Unit Tests ---\n");                     // print test start banner

    assert(register_adder(15, 25) == 40);                       // test basic addition logic
    printf("[PASS] Basic Addition\n");                          // confirm test passed

    assert(register_adder(0, 100) == 100);                      // test zero addition edge case
    printf("[PASS] Edge Case (Zero)\n");                        // confirm test passed

    assert(register_adder(2147483647, 1) == 2147483647);        // test overflow protection
    printf("[PASS] Overflow Mitigation\n");                     // confirm test passed

    printf("--- All Tests Passed ---\n");                       // print final success banner
    return 0;                                                   // exit program cleanly
}