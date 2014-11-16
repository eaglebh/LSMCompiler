CPP_FLAGS=-g -std=c++11

all: compiler

debug: compiler

scanner.cpp: scanner.ll parser.cpp
	flex -d -oscanner.cpp scanner.ll

parser.cpp: parser.yy
	bison -d --defines=parser.h -o parser.cpp parser.yy

scanner.o: scanner.cpp parser.cpp
	g++ ${CPP_FLAGS} -c scanner.cpp

parser.o: parser.cpp scanner.o
	g++ ${CPP_FLAGS} -c parser.cpp

Symbol.o: Symbol.cpp
	g++ ${CPP_FLAGS} -c Symbol.cpp

SymbolStack.o: SymbolStack.cpp
	g++ ${CPP_FLAGS} -c SymbolStack.cpp

main.o: main.cpp
	g++ ${CPP_FLAGS} -c main.cpp

compiler: Symbol.o SymbolStack.o scanner.o parser.o main.o
	g++ ${CPP_FLAGS} -o compiler main.o parser.o scanner.o SymbolStack.o Symbol.o

clean:
	rm -rf *.o compiler scanner.cpp parser.cpp parser.h stack.hh parser.output

cleandebug: clean

cleanall: clean
