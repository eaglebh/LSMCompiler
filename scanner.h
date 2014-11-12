#ifndef SCANNER_H
#define SCANNER_H

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "parser.h"

class LSMScanner : public yyFlexLexer {
    public :
        int yylex(yy::LSMParser::semantic_type *lval)
        {
            yylval = lval;
            return( yylex() );
        }

    yy::LSMParser::semantic_type *yylval;
    int yylex();
    
};

#endif
