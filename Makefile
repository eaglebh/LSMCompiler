all: test

scanner.cpp: scanner.ll parser.cpp
	flex -v -d -oscanner.cpp scanner.ll

parser.cpp: parser.yy
	bison -d --defines=parser.h -o parser.cpp parser.yy

scanner.o: scanner.cpp parser.cpp
	g++ -g -c scanner.cpp

parser.o: parser.cpp scanner.o 
	g++ -g -c parser.cpp

test.o: test.cpp 
	g++ -g -c test.cpp

test: scanner.o parser.o test.o
	g++ -g -o test test.o parser.o scanner.o struct/list.c struct/object.c struct/queue.c struct/stack.c struct/symbol.c

clean:
	rm -rf *.o test scanner.cpp parser.cpp parser.h stack.hh parser.output
