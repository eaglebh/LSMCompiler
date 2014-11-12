#include "scanner.h"
#include "parser.h"
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "struct/symbol.h"
#include "struct/stack.h"

using namespace std;

t_stack *ts;
t_stack *aux;
t_stack *parameters;
t_stack *labels;

int main(int argc, char ** argv)
{
	ts = stack_create();
    aux  = stack_create();
    parameters = stack_create();
    labels = stack_create();

	LSMScanner scanner;
	yy::LSMParser parser(scanner);
	parser.parse();
	//yyparse();
	return 0;
}
