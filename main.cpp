#include "scanner.h"
#include "parser.h"
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "struct/object.h"
#include "struct/list.h"

using namespace std;

SymbolStack *ts;
SymbolStack *aux;
SymbolStack *parameters;
SymbolStack *labels;

int main(int argc, char ** argv)
{
	ts = new SymbolStack();
    aux  = new SymbolStack();
    parameters = new SymbolStack();
    labels = new SymbolStack();

	LSMScanner scanner;
	yy::LSMParser parser(scanner);
	parser.parse();
	//yyparse();
	return 0;
}
