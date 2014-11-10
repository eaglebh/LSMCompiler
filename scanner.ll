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
#define OUT(STR) printf("%s ", STR);
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
\, { OUT(","); SAVE_AND_COUNT; return(token::COMMA); }
\; { OUT(";"); SAVE_AND_COUNT; return(token::SEMICOLON); }
\. { OUT("."); SAVE_AND_COUNT; return(token::DOT); }
\( { OUT("("); SAVE_AND_COUNT; return(token::LPAREN); }
\) { OUT(")"); SAVE_AND_COUNT; return(token::RPAREN); }
\[ { OUT("["); SAVE_AND_COUNT; return(token::LBRACKET); }
\] { OUT("]"); SAVE_AND_COUNT; return(token::RBRACKET); }
\: { OUT(":"); SAVE_AND_COUNT; return(token::COLON); }
program { OUT("PROGRAM"); SAVE_AND_COUNT; return(token::PROGRAM); }
{DIGIT}+ { OUT("UINT"); SAVE_AND_COUNT; return(token::UINT); }
if { OUT("IF"); SAVE_AND_COUNT; return(token::IF); }
while { OUT("WHILE"); SAVE_AND_COUNT; return(token::WHILE); }
do { OUT("DO"); SAVE_AND_COUNT; return(token::DO); }
label { OUT("LABEL"); SAVE_AND_COUNT; return(token::LABEL); }
declare { OUT("DECLARE"); SAVE_AND_COUNT; return(token::DECLARE); }
end { OUT("END"); SAVE_AND_COUNT; return(token::END); }
integer { OUT("INTEGER"); SAVE_AND_COUNT; return(token::INTEGER); }
real { OUT("REAL"); SAVE_AND_COUNT; return(token::REAL); }
boolean { OUT("BOOLEAN"); SAVE_AND_COUNT; return(token::BOOLEAN); }
char { OUT("CHAR"); SAVE_AND_COUNT; return(token::CHAR); }
array { OUT("ARRAY"); SAVE_AND_COUNT; return(token::ARRAY); }
of { OUT("OF"); SAVE_AND_COUNT; return(token::OF); }
procedure { OUT("PROCEDURE"); SAVE_AND_COUNT; return(token::PROCEDURE); }
then { OUT("THEN"); SAVE_AND_COUNT; return(token::THEN); }
else { OUT("ELSE"); SAVE_AND_COUNT; return(token::ELSE); }
until { OUT("UNTIL"); SAVE_AND_COUNT; return(token::UNTIL); }
read { OUT("READ"); SAVE_AND_COUNT; return(token::READ); }
write { OUT("WRITE"); SAVE_AND_COUNT; return(token::WRITE); }
goto { OUT("GOTO"); SAVE_AND_COUNT; return(token::GOTO); }
return { OUT("RETURN"); SAVE_AND_COUNT; return(token::RETURN); }
not { OUT("NOT"); SAVE_AND_COUNT; return(token::NOT); }
or { OUT("OR"); SAVE_AND_COUNT; return(token::OR); }
and { OUT("AND"); SAVE_AND_COUNT; return(token::AND); }
false { OUT("FALSE"); SAVE_AND_COUNT; return(token::FALSE); }
true { OUT("TRUE"); SAVE_AND_COUNT; return(token::TRUE); }
":=" { OUT("ASSIGNOP"); SAVE_AND_COUNT; return(token::ASSIGNOP); }
=|<|<=|>|>=|!= { OUT("RELOP"); SAVE_AND_COUNT; return(token::RELOP); }
\+ { OUT("PLUS"); SAVE_AND_COUNT; return(token::PLUS); }
\- { OUT("MINUS"); SAVE_AND_COUNT; return(token::MINUS); }
\* { OUT("TIMES"); SAVE_AND_COUNT; return(token::TIMES); }
\/ { OUT("DIV"); SAVE_AND_COUNT; return(token::DIV); }
{LETTER} { OUT("ID"); SAVE_AND_COUNT; return(token::ID); }
. { return token::UNKNOWN; }
<<EOF>> { yyterminate(); }
%%
