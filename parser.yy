%skeleton "lalr1.cc"
%defines
%define parser_class_name {LSMParser}

%code requires{
    class LSMScanner;
}

%error-verbose
%parse-param { LSMScanner  &scanner  }

%code{
    #include <cstdio>
    #include <cstdlib>
    #include <vector>
    
    #include "scanner.h"

    #undef yylex
    #define yylex scanner.yylex
}

/* Represents the many different ways we can access our data */
%union {
    int token;
}

%start program
%token PROGRAM
%token UNKNOWN
%token <uint_type>  UINT
%token <string>     ID
%token <string>     IF WHILE DO LABEL
%token <string>     DECLARE END INTEGER REAL BOOLEAN CHAR ARRAY OF PROCEDURE THEN ELSE UNTIL FALSE TRUE
%token <token>      READ WRITE GOTO RETURN
%token <token>      NOT OR AND
%token <token>      ASSIGNOP
%token <token>      RELOP ADDOP MULOP SIGN
%token <string>     DIGIT LETTER
%token <token>      COMMA SEMI_COLON DOT OPEN_PARENS CLOSE_PARENS OPEN_BRACK CLOSE_BRACK TWO_DOTS 
%token <string>     EXP STRING

/* operator precedence */
%left '+' '-'
%left '*' '/'


%%
program         : PROGRAM identifier proc_body ;
proc_body       : block_stmt ;
block_stmt      : DECLARE decl_list DO stmt_list END 
                | DO stmt_list END ;
decl_list       : decl 
                | decl_list SEMI_COLON decl ;
decl            : variable_decl 
                | proc_decl;
variable_decl   : type ident_list ;
ident_list      : identifier 
                | ident_list COMMA identifier ;
type            : simple_type 
                | array_type;
simple_type     : INTEGER  
                | REAL 
                | BOOLEAN 
                | CHAR 
                | LABEL ;
array_type      : ARRAY tamanho OF simple_type;
tamanho         : integer_constant;
proc_decl       : proc_header block_stmt ;
proc_header     : PROCEDURE identifier  
                | PROCEDURE identifier OPEN_PARENS formal_list CLOSE_PARENS ;
formal_list     : parameter_decl  
                | formal_list SEMI_COLON parameter_decl ;
parameter_decl  : parameter_type identifier;
parameter_type  : type 
                | proc_signature;
proc_signature  : PROCEDURE identifier OPEN_PARENS type_list CLOSE_PARENS 
                | PROCEDURE identifier;
type_list       : parameter_type 
                | type_list COMMA parameter_type;
stmt_list       : stmt 
                | stmt_list SEMI_COLON stmt ;
stmt            : LABEL TWO_DOTS unlabelled_stmt 
                | unlabelled_stmt;
label           : identifier;
unlabelled_stmt : assign_stmt 
                | if_stmt 
                | loop_stmt 
                | read_stmt 
                | write_stmt
                | goto_stmt 
                | proc_stmt 
                | return_stmt 
                | block_stmt;
assign_stmt     : variable ASSIGNOP expression;
variable        : identifier 
                | array_element;
array_element   : identifier OPEN_BRACK expression CLOSE_BRACK ;
if_stmt         : IF condition THEN stmt_list END    
                | IF condition THEN stmt_list ELSE stmt_list END;
condition       : expression;
loop_stmt       : stmt_prefix stmt_list stmt_suffix;
stmt_prefix     : WHILE condition DO 
                | DO;
stmt_suffix     : UNTIL condition 
                | END;
read_stmt       : READ OPEN_PARENS ident_list CLOSE_PARENS;
write_stmt      : WRITE OPEN_PARENS expr_list CLOSE_PARENS;
goto_stmt       : GOTO label;
proc_stmt       : identifier OPEN_PARENS expr_list CLOSE_PARENS 
                | identifier;
return_stmt     : RETURN;
expr_list       : expression  
                | expr_list COMMA expression;
expression      : simple_expr 
                | simple_expr comparison simple_expr ;
simple_expr     : term 
                | simple_expr ADDOP term ;
term            : factor_a 
                | term MULOP factor_a ;
factor_a        : factor 
                | NOT factor 
                | SIGN factor ;
factor          : variable 
                | constant 
                | OPEN_PARENS expression CLOSE_PARENS ;
constant        : integer_constant 
                | real_constant 
                | char_constant 
                | boolean_constant ;
comparison      : RELOP;
boolean_constant: FALSE 
                | TRUE;
integer_constant: unsigned_integer;
unsigned_integer: DIGIT ;
real_constant   : unsigned_real;
unsigned_real   : unsigned_integer DOT unsigned_integer scale_factor
                | unsigned_integer DOT unsigned_integer
                | unsigned_integer scale_factor
                | unsigned_integer ;
scale_factor    : EXP SIGN unsigned_integer;
char_constant   : STRING;
identifier      : ID ;
%%

void yy::LSMParser::error( const std::string &err_message )
{
    std::cerr << "Error: " << err_message << "\n";
}

