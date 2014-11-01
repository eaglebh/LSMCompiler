all: test

scanner.c: scanner.l parser.c
	flex -d -oscanner.c scanner.l

parser.c: parser.y
	bison -d -v --defines=parser.h -o parser.c parser.y

scanner.o: scanner.c parser.c
	gcc -g -c scanner.c

parser.o: parser.c scanner.o 
	gcc -g -c parser.c

test.o: test.cpp 
	gcc -g -c test.cpp

compiladorF.o: compiladorF.c
	gcc -g -c compiladorF.c

test: scanner.o parser.o compiladorF.o
	gcc -g -o test parser.o scanner.o compiladorF.o tabelasimb.c pilha.c aux.c trataerro.c -ll -ly -lc

clean:
	rm -rf *.o test scanner.c parser.c parser.h stack.hh
