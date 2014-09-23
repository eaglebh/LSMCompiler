%name LSMParser
%define LSP_NEEDED
%define MEMBERS                 \
    virtual ~LSMParser()   {} \
    private:                   \
       LSMScanner scanner;
%define LEX_BODY {return scanner.yylex();}
%define ERROR_BODY = 0

%header{
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "scanner.h"
using namespace std;
%}

%union {
       int i_type;
}

%start program
%token PROGRAM
%token UNKNOWN
%token <uint_type> UNSIGNED_INTEGER
%token <id>        ID
%token <lbls>      IF WHILE DO LABEL
%token DECLARE END INTEGER REAL BOOLEAN CHAR ARRAY OF PROCEDURE THEN ELSE UNTIL 
%token READ WRITE GOTO RETURN
%token NOT OR AND FALSE TRUE
%token ASSIGNOP
%token RELOP ADDOP MULOP
%token SIGN DIGIT LETTER CHARACTER
%token COMMA SEMI_COLON DOT OPEN_PARENS CLOSE_PARENS OPEN_BRACK CLOSE_BRACK TWO_DOTS APOST

%type <uint_type> unsigned_integer


/* operator precedence */
%left '+' '-'
%left '*' '/'


%%
program 	: PROGRAM ID proc_body;
proc_body 	: block_stmt;
block_stmt 	: DECLARE decl_list DO stmt_list END
    		| DO stmt_list END;
decl_list	: decl | decl_list SEMI_COLON decl;
decl		: variable_decl | proc_decl;
variable_decl	: type ident_list;
ident_list	: ID | ident_list COMMA ID;
type		: simple_type | array_type;
simple_type	: INTEGER | REAL | BOOLEAN | CHAR | LABEL;
array_type	: ARRAY tamanho OF simple_type;
tamanho		: integer_constant;
proc_decl	: proc_header block_stmt;
proc_header	: PROCEDURE ID | PROCEDURE ID OPEN_PARENS formal_list CLOSE_PARENS;
formal_list	: parameter_decl | formal_list SEMI_COLON parameter_decl;
parameter_decl	: parameter_type ID;
parameter_type	: type | proc_signature;
proc_signature	: PROCEDURE ID OPEN_PARENS type_list CLOSE_PARENS | PROCEDURE ID;
type_list	: parameter_type | type_list COMMA parameter_type;
stmt_list	: stmt | stmt_list SEMI_COLON stmt;
stmt		: LABEL TWO_DOTS unlabelled_stmt | unlabelled_stmt;
label		: identifier;
unlabelled_stmt	: assign_stmt | if_stmt | loop_stmt | read_stmt | write_stmt	
		|	goto_stmt | proc_stmt | return_stmt | block_stmt;
assign_stmt	: variable ASSIGNOP expression;
variable	: ID | array_element;
array_element	: ID OPEN_BRACK expression CLOSE_BRACK;
if_stmt		: IF condition THEN stmt_list END	
		|	IF condition THEN stmt_list ELSE stmt_list END;
condition	: expression;
loop_stmt	: stmt_prefix stmt_list stmt_suffix;
stmt_prefix	: WHILE condition DO | DO;
stmt_suffix	: UNTIL condition | END;
read_stmt	: READ OPEN_PARENS ident_list CLOSE_PARENS;
write_stmt	: WRITE OPEN_PARENS expr_list CLOSE_PARENS;
goto_stmt	: GOTO label;
proc_stmt	: ID OPEN_PARENS expr_list CLOSE_PARENS |	ID;
return_stmt	: RETURN;
expr_list	: expression | expr_list COMMA expression;
expression	: simple_expr | simple_expr RELOP simple_expr;
simple_expr	: term | simple_expr ADDOP term;
term		: factor_a | term MULOP factor_a;
factor_a 	: factor | NOT factor | SIGN factor;
factor		: variable | constant | OPEN_PARENS expression CLOSE_PARENS;
constant	: integer_constant | real_constant | char_constant | boolean_constant;
boolean_constant: FALSE | TRUE;
integer_constant: unsigned_integer;
unsigned_integer: DIGIT;
real_constant	: unsigned_real;
unsigned_real	: unsigned_integer DOT DIGIT scale_factor
    		| unsigned_integer DOT DIGIT
    		| unsigned_integer scale_factor
    		| unsigned_integer;
scale_factor	: 'E' SIGN unsigned_integer;
char_constant	: APOST CHARACTER APOST;
identifier	: LETTER | LETTER DIGIT;
%%
