%option c++
%option yyclass="LSMScanner"
%option noyywrap

%{
#include<sstream>
#include "scanner.h"
#include "parser.h"
#include <cstdlib>

//#define OUT(STR) printf("%-20s # %s \n", STR, token);
//#define OUT(STR) printf("%-20s\n", STR);
#define OUT(STR) printf("%s ", STR);
%}

DIGIT   [0-9]
LETTER	[a-zA-Z][a-zA-Z0-9]*
DISCARD [\t ]+
PRINTED '[^'\n]*'

%%
{DISCARD}
\n { OUT("\n"); }
{PRINTED} { OUT("STRING"); return(LSMParser::STRING); } 
\, { OUT(","); return(LSMParser::COMMA); }
\; { OUT(";"); return(LSMParser::SEMI_COLON); }
\. { OUT("."); return(LSMParser::DOT); }
\( { OUT("("); return(LSMParser::OPEN_PARENS); }
\) { OUT(")"); return(LSMParser::CLOSE_PARENS); }
\[ { OUT("["); return(LSMParser::OPEN_BRACK); }
\] { OUT("]"); return(LSMParser::CLOSE_BRACK); }
\: { OUT(":"); return(LSMParser::TWO_DOTS); }
program { OUT("PROGRAM"); return(LSMParser::PROGRAM); }
{DIGIT}+ { OUT("UINT"); return(LSMParser::UINT); }
if { OUT("IF"); return(LSMParser::IF); }
while { OUT("WHILE"); return(LSMParser::WHILE); }
do { OUT("DO"); return(LSMParser::DO); }
label { OUT("LABEL"); return(LSMParser::LABEL); }
declare { OUT("DECLARE"); return(LSMParser::DECLARE); }
end { OUT("END"); return(LSMParser::END); }
integer { OUT("INTEGER"); return(LSMParser::INTEGER); }
real { OUT("REAL"); return(LSMParser::REAL); }
boolean { OUT("BOOLEAN"); return(LSMParser::BOOLEAN); }
char { OUT("CHAR"); return(LSMParser::CHAR); }
array { OUT("ARRAY"); return(LSMParser::ARRAY); }
of { OUT("OF"); return(LSMParser::OF); }
procedure { OUT("PROCEDURE"); return(LSMParser::PROCEDURE); }
then { OUT("THEN"); return(LSMParser::THEN); }
else { OUT("ELSE"); return(LSMParser::ELSE); }
until { OUT("UNTIL"); return(LSMParser::UNTIL); }
read { OUT("READ"); return(LSMParser::READ); }
write { OUT("WRITE"); return(LSMParser::WRITE); }
goto { OUT("GOTO"); return(LSMParser::GOTO); }
return { OUT("RETURN"); return(LSMParser::RETURN); }
not { OUT("NOT"); return(LSMParser::NOT); }
or { OUT("OR"); return(LSMParser::OR); }
and { OUT("AND"); return(LSMParser::AND); }
false { OUT("FALSE"); return(LSMParser::FALSE); }
true { OUT("TRUE"); return(LSMParser::TRUE); }
":=" { OUT("ASSIGNOP"); return(LSMParser::ASSIGNOP); }
=|<|<=|>|>=|!= { OUT("RELOP"); return(LSMParser::RELOP); } 
\+|-|or { OUT("ADDOP"); return(LSMParser::ADDOP); }
\*|\/|and { OUT("MULOP"); return(LSMParser::MULOP); }
[-+]* { OUT("SIGN"); return(LSMParser::SIGN); }
{LETTER} { OUT("ID"); return(LSMParser::ID); }
. { return LSMParser::UNKNOWN; }
<<EOF>> { yyterminate(); }
%%

