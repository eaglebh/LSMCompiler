#ifndef SCANNER_H
#define SCANNER_H

#include <FlexLexer.h>

class LSMScanner : public yyFlexLexer {
      public :
      int yylex();
};

#endif
