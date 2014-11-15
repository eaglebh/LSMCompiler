%{
#include <sstream>
#include <string>
#include <cstdlib>
#include <vector>
#include "scanner.h"
#include "parser.h"

using namespace yy;

typedef LSMParser::token token;

#define SAVE_AND_COUNT { yylval->string = new std::string(yytext, yyleng); }
//#define OUT(STR) printf("%s ", STR);
#define OUT(STR) ;
#define TOKEN(t) (yylval.token = t)

%}

%option nodefault
%option yyclass="LSMScanner"
%option noyywrap
%option c++

DIGIT   [0-9]
LETTER	[a-zA-Z_][a-zA-Z0-9]*
DISCARD [\t ]+
PRINTED '[^'\n]*'

%%
{DISCARD}
\n { OUT("\n"); }
{PRINTED} { OUT("STRING"); SAVE_AND_COUNT; return(token::STRING); }
\, { OUT(","); ; return(token::COMMA); }
\; { OUT(";"); ; return(token::SEMICOLON); }
\. { OUT("."); ; return(token::DOT); }
\( { OUT("("); ; return(token::LPAREN); }
\) { OUT(")"); ; return(token::RPAREN); }
\[ { OUT("["); ; return(token::LBRACKET); }
\] { OUT("]"); ; return(token::RBRACKET); }
\: { OUT(":"); ; return(token::COLON); }
program { OUT("PROGRAM"); ; return(token::PROGRAM); }
{DIGIT}+ { OUT("UINT"); SAVE_AND_COUNT; return(token::UINT); }
if { OUT("IF"); ; return(token::IF); }
while { OUT("WHILE"); ; return(token::WHILE); }
do { OUT("DO"); ; return(token::DO); }
label { OUT("LABEL"); ; return(token::LABEL); }
declare { OUT("DECLARE"); ; return(token::DECLARE); }
end { OUT("END"); ; return(token::END); }
integer { OUT("INTEGER"); ; return(token::INTEGER); }
real { OUT("REAL"); ; return(token::REAL); }
boolean { OUT("BOOLEAN"); ; return(token::BOOLEAN); }
char { OUT("CHAR"); ; return(token::CHAR); }
array { OUT("ARRAY"); ; return(token::ARRAY); }
of { OUT("OF"); ; return(token::OF); }
procedure { OUT("PROCEDURE"); ; return(token::PROCEDURE); }
then { OUT("THEN"); ; return(token::THEN); }
else { OUT("ELSE"); ; return(token::ELSE); }
until { OUT("UNTIL"); ; return(token::UNTIL); }
read { OUT("READ"); ; return(token::READ); }
write { OUT("WRITE"); ; return(token::WRITE); }
goto { OUT("GOTO"); ; return(token::GOTO); }
return { OUT("RETURN"); ; return(token::RETURN); }
not { OUT("NOT"); ; return(token::NOT); }
or { OUT("OR"); ; return(token::OR); }
and { OUT("AND"); ; return(token::AND); }
false { OUT("FALSE"); ; return(token::FALSE); }
true { OUT("TRUE"); ; return(token::TRUE); }
":=" { OUT("ASSIGNOP"); ; return(token::ASSIGNOP); }
"="  { OUT("EQL"); ; return(token::EQL); }
"<"  { OUT("LSS"); ; return(token::LSS); }
"<=" { OUT("LEQ"); ; return(token::LEQ); }
">"  { OUT("GTR"); ; return(token::GTR); }
">=" { OUT("GEQ"); ; return(token::GEQ); }
"!=" { OUT("NEQ"); ; return(token::NEQ); }
\+ { OUT("PLUS"); ; return(token::PLUS); }
\- { OUT("MINUS"); ; return(token::MINUS); }
\* { OUT("TIMES"); ; return(token::TIMES); }
\/ { OUT("DIV"); ; return(token::DIV); }
{LETTER} { OUT("ID"); SAVE_AND_COUNT; return(token::ID); }
. { return token::UNKNOWN; }
<<EOF>> { yyterminate(); }
%%
