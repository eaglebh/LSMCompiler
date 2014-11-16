#include "scanner.h"
#include "parser.h"

int main(int argc, char ** argv)
{
	LSMScanner scanner;
	yy::LSMParser parser(scanner);
	parser.parse();

	return 0;
}
