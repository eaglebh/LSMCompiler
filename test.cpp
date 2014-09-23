#include "scanner.h"
#include "parser.h"
#include <iostream>
using namespace std;
int main(int argc, char ** argv)
{
       LSMScanner scanner;
       scanner.yylex();
       return 0;
}
