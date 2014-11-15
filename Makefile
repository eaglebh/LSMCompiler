all: test

debug: test

scanner.cpp: scanner.ll parser.cpp
	flex -d -oscanner.cpp scanner.ll

parser.cpp: parser.yy
	bison -d --defines=parser.h -o parser.cpp parser.yy

scanner.o: scanner.cpp parser.cpp
	g++ -g -c scanner.cpp

parser.o: parser.cpp scanner.o
	g++ -g -c parser.cpp

main.o: main.cpp
	g++ -g -c main.cpp

test: scanner.o parser.o main.o
	g++ -g -o test main.o parser.o scanner.o struct/list.cpp struct/object.cpp

clean:
	rm -rf *.o test scanner.cpp parser.cpp parser.h stack.hh parser.output

cleandebug: clean

cleanall: clean
