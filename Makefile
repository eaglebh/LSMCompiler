all: test

scanner.cpp: scanner.ll parser.cpp
	flex -d -oscanner.cpp scanner.ll

parser.cpp: parser.yy
	bison -d --defines=parser.h -o parser.cpp parser.yy

scanner.o: scanner.cpp parser.cpp
	g++ -c scanner.cpp

parser.o: parser.cpp scanner.o 
	g++ -c parser.cpp

test.o: test.cpp 
	g++ -c test.cpp

test: scanner.o parser.o test.o
	g++ -o test test.o parser.o scanner.o

clean:
	rm -rf *.o test scanner.cpp parser.cpp parser.h
