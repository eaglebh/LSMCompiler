#include "parser.h"
#include <FlexLexer.h>
#include <iostream>
using namespace std;
int main(int argc, char ** argv)
{
       Scanner scanner;
       scanner.yylex();
       return 0;
}
