%skeleton "lalr1.cc"
%defines
%define parser_class_name {LSMParser}

%code requires{
    class LSMScanner;
}

%error-verbose
%parse-param { LSMScanner  &scanner  }

%code{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "struct/symbol.h"
    #include "struct/stack.h"

    #include "scanner.h"

    #undef yylex
    #define yylex scanner.yylex

    void yyerror(const char * format, ...);

    extern char *yytext;

    t_stack *ts;
    t_stack *aux;
    t_stack *parameters;
    t_stack *labels;

    t_symbol *symbol1 = NULL;
    t_symbol *symbol2 = NULL;
    t_symbol *symb_atr = NULL;
    t_symbol *symb_proc = NULL;

    int nl = -1;
    int offset = 0;
    int nvars;        // Número de variáveis locais
    int nparam;        // Número do parâmetro
    int label = 0;
    int write = 0;  // Variável condicional para indicar o uso de write()
    int read = 0;  // Variável condicional para indicar o uso de read()
    int is_label = 0;

    char *const_value = NULL;
    int const_number = 0;
    int integer_part = 0;
    int fractional_part = 0;
    int fractional_part_length = 0;
    int coefficient = 0;
    int exponent = 0;

    #define MAXNUMSTR 10

    int deb_line = 0;

    #define gen_code(...) { deb_line = __LINE__; pgen_code(__VA_ARGS__); }

    void pgen_code(const char * format, ...) {
        char buffer[256];
        va_list args;
        va_start (args, format);
        vsprintf (buffer,format, args);
        va_end (args);

        //printf ("%d %s",deb_line, buffer);
        printf ("%s", buffer);
    }

    int write_label(void) {
        int l = label;
        gen_code("R%03d", label);
        label++;
        return l;
    }
}

/* Represents the many different ways we can access our data */
%union {
    int token;
    std::string *string;
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
%token <token>      RELOP PLUS MINUS TIMES DIV
%token <string>     DIGIT LETTER
%token <token>      COMMA SEMICOLON DOT LPAREN RPAREN LBRACKET RBRACKET COLON 
%token <string>     EXP STRING

/* operator precedence */
%left '+' '-'
%left '*' '/'


%%
program         : PROGRAM identifier proc_body ;

proc_body       : block_stmt ;

block_stmt      : DECLARE {printf("dd");} decl_list {printf("dl");} DO stmt_list END { printf("[declare=%s]",yylhs.value.string->c_str()); }
                | DO stmt_list END { printf("[do=%s]",yylhs.value.string->c_str()); };

decl_list       : decl 
                | decl_list SEMICOLON decl ;

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

proc_header     : PROCEDURE identifier LPAREN formal_list RPAREN
                | PROCEDURE identifier   ;

formal_list     : parameter_decl  
                | formal_list SEMICOLON parameter_decl ;

parameter_decl  : parameter_type identifier;

parameter_type  : type 
                | proc_signature;

proc_signature  : PROCEDURE identifier LPAREN type_list RPAREN 
                | PROCEDURE identifier;

type_list       : parameter_type 
                | type_list COMMA parameter_type;

stmt_list       : stmt 
                | stmt_list SEMICOLON stmt ;

stmt            : identifier COLON unlabelled_stmt 
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

assign_stmt     : variable {printf(" variable");} ASSIGNOP {printf(" assign");} expression {printf(" expression");};

variable        : identifier {printf(" vi");}
                | array_element {printf(" va");};

variable_list   : variable 
                | variable_list COMMA variable ;                

array_element   : identifier LBRACKET expression RBRACKET ;

if_stmt         : IF condition THEN stmt_list END    
                | IF condition THEN stmt_list ELSE stmt_list END;

condition       : expression;

loop_stmt       : WHILE condition DO stmt_list END
                | DO stmt_list UNTIL condition;

read_stmt       : READ LPAREN variable_list RPAREN;

write_stmt      : WRITE LPAREN expr_list RPAREN;

goto_stmt       : GOTO label;

proc_stmt       : identifier LPAREN expr_list RPAREN 
                | identifier;

return_stmt     : RETURN;

expr_list       : expression  
                | expr_list COMMA expression;

expression      : simple_expr {printf("simple_expr1");}
                | simple_expr {printf("simple_expr2");} comparison {printf("comparison");} simple_expr {printf("simple_expr2.1");} ;

simple_expr     : term {printf("term");}
                | simple_expr {printf("simple_expr4");} PLUS term
                | simple_expr {printf("simple_expr5");} MINUS term
                | simple_expr {printf("simple_expr6");} OR term
                ;

term            : factor_a 
                | term TIMES factor_a 
                | term DIV factor_a 
                | term AND factor_a 
                ;

factor_a        : factor 
                | NOT factor 
                | PLUS factor 
                | MINUS factor 
                | OR factor 
;

factor          : variable 
                | constant 
                | LPAREN expression RPAREN ;

constant        : integer_constant 
                | real_constant 
                | char_constant 
                | boolean_constant ;

comparison      : RELOP;

boolean_constant: FALSE 
                | TRUE;

integer_constant: unsigned_integer;

unsigned_integer: UINT { printf("[uint=%s]",yylhs.value.string->c_str()); };

real_constant   : unsigned_real;

unsigned_real   : unsigned_integer DOT unsigned_integer scale_factor
                | unsigned_integer DOT unsigned_integer
                | unsigned_integer scale_factor ;

scale_factor    : "E" "+" unsigned_integer
                | "E" "-" unsigned_integer;

char_constant   : STRING  ;

identifier      : ID { printf("[id=%s]",yylhs.value.string->c_str()); } ;
%%

void yy::LSMParser::error( const std::string &err_message )
{
    std::cerr << "Error: " << err_message << "\n";
}

void yyerror(const char * format, ...) {
    char buffer[256];
    va_list args;
    va_start (args, format);
    vsprintf (buffer,format, args);
    va_end (args);

    fprintf (stderr, "erro: %s\n",buffer);

    exit(EXIT_FAILURE);
}
