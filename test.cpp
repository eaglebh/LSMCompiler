#include "scanner.h"
#include "parser.h"
#include <iostream>
using namespace std;
int main(int argc, char ** argv)
{
       LSMScanner scanner;
       while(scanner.yylex());
       return 0;
}
