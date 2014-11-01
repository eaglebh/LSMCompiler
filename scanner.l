%{
#include <stdlib.h>
#include <stdio.h>
#include "compilador.h"
#include "scanner.h"
#include "parser.h"

int nl = 1;

#define SAVE_AND_COUNT { strncpy (token, yytext, TAM_TOKEN); }
#define OUT(STR) printf("%s ", STR);

%}

DIGIT   [0-9]
LETTER	[a-zA-Z_][a-zA-Z0-9]*
DISCARD [\t ]+
PRINTED '[^'\n]*'

%%
{DISCARD}
\n { OUT("\n"); }
{PRINTED} { OUT("STRING"); SAVE_AND_COUNT; return(STRING); }
\, { OUT(","); SAVE_AND_COUNT; return(COMMA); }
\; { OUT(";"); SAVE_AND_COUNT; return(SEMI_COLON); }
\. { OUT("."); SAVE_AND_COUNT; return(DOT); }
\( { OUT("("); SAVE_AND_COUNT; return(OPEN_PARENS); }
\) { OUT(")"); SAVE_AND_COUNT; return(CLOSE_PARENS); }
\[ { OUT("["); SAVE_AND_COUNT; return(OPEN_BRACK); }
\] { OUT("]"); SAVE_AND_COUNT; return(CLOSE_BRACK); }
\: { OUT(":"); SAVE_AND_COUNT; return(TWO_DOTS); }
program { OUT("PROGRAM"); SAVE_AND_COUNT; return(PROGRAM); }
{DIGIT}+ { OUT("UINT"); SAVE_AND_COUNT; return(UINT); }
if { OUT("IF"); SAVE_AND_COUNT; return(IF); }
while { OUT("WHILE"); SAVE_AND_COUNT; return(WHILE); }
do { OUT("DO"); SAVE_AND_COUNT; return(DO); }
label { OUT("LABEL"); SAVE_AND_COUNT; return(LABEL); }
declare { OUT("DECLARE"); SAVE_AND_COUNT; return(DECLARE); }
end { OUT("END"); SAVE_AND_COUNT; return(END); }
integer { OUT("INTEGER"); SAVE_AND_COUNT; return(INTEGER); }
real { OUT("REAL"); SAVE_AND_COUNT; return(REAL); }
boolean { OUT("BOOLEAN"); SAVE_AND_COUNT; return(BOOLEAN); }
char { OUT("CHAR"); SAVE_AND_COUNT; return(CHAR); }
array { OUT("ARRAY"); SAVE_AND_COUNT; return(ARRAY); }
of { OUT("OF"); SAVE_AND_COUNT; return(OF); }
procedure { OUT("PROCEDURE"); SAVE_AND_COUNT; return(PROCEDURE); }
then { OUT("THEN"); SAVE_AND_COUNT; return(THEN); }
else { OUT("ELSE"); SAVE_AND_COUNT; return(ELSE); }
until { OUT("UNTIL"); SAVE_AND_COUNT; return(UNTIL); }
read { OUT("READ"); SAVE_AND_COUNT; return(READ); }
write { OUT("WRITE"); SAVE_AND_COUNT; return(WRITE); }
goto { OUT("GOTO"); SAVE_AND_COUNT; return(GOTO); }
return { OUT("RETURN"); SAVE_AND_COUNT; return(RETURN); }
not { OUT("NOT"); SAVE_AND_COUNT; return(NOT); }
or { OUT("OR"); SAVE_AND_COUNT; return(ADDOP); }
and { OUT("AND"); SAVE_AND_COUNT; return(MULOP); }
false { OUT("FALSE"); SAVE_AND_COUNT; return(FALSE); }
true { OUT("TRUE"); SAVE_AND_COUNT; return(TRUE); }
":=" { OUT("ASSIGNOP"); SAVE_AND_COUNT; return(ASSIGNOP); }
=|<|<=|>|>=|!= { OUT("RELOP"); SAVE_AND_COUNT; return(RELOP); }
\+|-|or { OUT("ADDOP"); SAVE_AND_COUNT; return(ADDOP); }
\*|\/|and { OUT("MULOP"); SAVE_AND_COUNT; return(MULOP); }
{LETTER} { OUT("ID"); SAVE_AND_COUNT; return(ID); }
. { return UNKNOWN; }
<<EOF>> { yyterminate(); }
%%
