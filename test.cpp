#include "scanner.h"
#include "parser.h"
#include <iostream>
using namespace std;
int main(int argc, char ** argv)
{
    LSMScanner scanner;
       yy::LSMParser parser(scanner);
       parser.parse();
       //yyparse();
       return 0;
}
