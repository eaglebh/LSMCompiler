all: test

scanner.cpp: scanner.l
	flex++ -d -oscanner.cpp scanner.l

parser.cpp: parser.y
	bison++ -d -hparser.h -o parser.cpp parser.y

scanner.o: scanner.cpp parser.o
	g++ -c scanner.cpp

parser.o: parser.cpp 
	g++ -c parser.cpp

test.o: test.cpp 
	g++ -c test.cpp

test: scanner.o parser.o test.o
	g++ -o test test.o parser.o scanner.o

clean:
	rm -rf *.o test scanner.cpp parser.cpp
