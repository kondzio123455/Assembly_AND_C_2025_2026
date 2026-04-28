
# file: makefile
# author: konrad skoczylas c00309030
# description: compilation instructions for project


ASM=nasm
CC=gcc
AFLAGS=-f elf64
CFLAGS=-no-pie -g -Wall   👍

all: main test_suite

main: main.o registeradder.o
	$(CC) $(CFLAGS) -o main main.o registeradder.o

main.o: main.asm
	$(ASM) $(AFLAGS) main.asm -o main.o

test_suite: registeradder.o testmain.c
	$(CC) $(CFLAGS) -o test_suite testmain.c registeradder.o

registeradder.o: registeradder.asm
	$(ASM) $(AFLAGS) registeradder.asm -o registeradder.o

clean:
	rm -f *.o main test_suite
