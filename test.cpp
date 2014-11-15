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

t_list *ts;
t_list *aux;
t_list *parameters;
t_list *labels;

int main(int argc, char ** argv)
{
	ts = list_create();
    aux  = list_create();
    parameters = list_create();
    labels = list_create();

	LSMScanner scanner;
	yy::LSMParser parser(scanner);
	parser.parse();
	//yyparse();
	return 0;
}
