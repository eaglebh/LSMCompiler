%option c++
%option noyywrap

%{
//%option yyclass="LSMScanner"
//#include "scanner.h"
#include<sstream>
#include "parser.h"
#include <cstdlib>
//YY_CalcParser_STYPE val;

//#define OUT(STR) printf("%-20s # %s \n", STR, token);
#define OUT(STR) printf("%-20s\n", STR);
%}

DIGIT   [0-9]
LETTER	[a-zA-Z][a-zA-Z0-9]*
DISCARD [\t ]+

%%
{DISCARD}
\, { OUT(","); return(Parser::COMMA); }
\; { OUT(";"); return(Parser::SEMI_COLON); }
\. { OUT("."); return(Parser::DOT); }
\( { OUT("("); return(Parser::OPEN_PARENS); }
\) { OUT(")"); return(Parser::CLOSE_PARENS); }
\[ { OUT("["); return(Parser::OPEN_BRACK); }
\] { OUT("]"); return(Parser::CLOSE_BRACK); }
\: { OUT(":"); return(Parser::TWO_DOTS); }
\' { OUT("'"); return(Parser::APOST); }
program { OUT("PROGRAM"); return(Parser::PROGRAM); }
{DIGIT}+ { OUT("UNSIGNED_INTEGER"); return(Parser::UNSIGNED_INTEGER); }
if { OUT("IF"); return(Parser::IF); }
while { OUT("WHILE"); return(Parser::WHILE); }
do { OUT("DO"); return(Parser::DO); }
label { OUT("LABEL"); return(Parser::LABEL); }
declare { OUT("DECLARE"); return(Parser::DECLARE); }
end { OUT("END"); return(Parser::END); }
integer { OUT("INTEGER"); return(Parser::INTEGER); }
real { OUT("REAL"); return(Parser::REAL); }
boolean { OUT("BOOLEAN"); return(Parser::BOOLEAN); }
char { OUT("CHAR"); return(Parser::CHAR); }
array { OUT("ARRAY"); return(Parser::ARRAY); }
of { OUT("OF"); return(Parser::OF); }
procedure { OUT("PROCEDURE"); return(Parser::PROCEDURE); }
then { OUT("THEN"); return(Parser::THEN); }
else { OUT("ELSE"); return(Parser::ELSE); }
until { OUT("UNTIL"); return(Parser::UNTIL); }
read { OUT("READ"); return(Parser::READ); }
write { OUT("WRITE"); return(Parser::WRITE); }
goto { OUT("GOTO"); return(Parser::GOTO); }
return { OUT("RETURN"); return(Parser::RETURN); }
not { OUT("NOT"); return(Parser::NOT); }
or { OUT("OR"); return(Parser::OR); }
and { OUT("AND"); return(Parser::AND); }
false { OUT("FALSE"); return(Parser::FALSE); }
true { OUT("TRUE"); return(Parser::TRUE); }
":=" { OUT("ASSIGNOP"); return(Parser::ASSIGNOP); }
=|<|<=|>|>=|!= { OUT("RELOP"); return(Parser::RELOP); } 
\+|-|or { OUT("ADDOP"); return(Parser::ADDOP); }
\*|\/|and { OUT("MULOP"); return(Parser::MULOP); }
[-+]* { OUT("SIGN"); return(Parser::SIGN); }
{LETTER} { OUT("IDENTIFIER"); return(Parser::IDENTIFIER); }
[:print:] { OUT("CHARACTER"); return(Parser::CHARACTER); } 
.                 {
                   return Parser::UNKNOWN;
                 }
<<EOF>>           {
                   yyterminate();
                 }
\n
%%
