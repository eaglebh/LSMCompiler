%{
    #include <cstdio>
    #include <cstdlib>
    #include <vector>
    
    #include "node.h"
    NBlock *programBlock; /* the top level root node of our final AST */

    extern int yylex();
    void yyerror(const char *s) { std::printf("Error: %s\n", s);std::exit(1); }
%}

%defines

%error-verbose

%locations

/* Represents the many different ways we can access our data */
%union {
    Node *node;
    NBlock *block;
    NExpression *expr;
    NStatement *stmt;
    NIdentifier *ident;
    NVariableDeclaration *var_decl;
    std::vector<NVariableDeclaration*> *varvec;
    std::vector<NExpression*> *exprvec;
    std::string *string;
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

%type <ident> identifier
%type <expr> condition expression simple_expr term factor_a factor array_element assign_stmt variable
%type <varvec> formal_list ident_list
%type <exprvec> expr_list
%type <block> program proc_body block_stmt
%type <stmt> decl variable_decl proc_decl proc_header stmt_list decl_list 
%type <token> comparison
%type <string> type simple_type array_type char_constant integer_constant real_constant constant unsigned_integer unsigned_real boolean_constant

/* operator precedence */
%left '+' '-'
%left '*' '/'


%%
program         : PROGRAM identifier proc_body { programBlock = $3; };
proc_body       : block_stmt { $$ = new NBlock(); };
block_stmt      : DECLARE decl_list DO stmt_list END {
    $$->statements.push_back($<stmt>2); $$->statements.push_back($<stmt>4); }
                | DO stmt_list END { $$->statements.push_back($<stmt>2); };
decl_list       : decl { $$->statements.push_back($<stmt>1); }
                | decl_list SEMI_COLON decl { $$->statements.push_back($<stmt>3); };
decl            : variable_decl 
                | proc_decl;
variable_decl   : type ident_list { $$ = new NVariableDeclaration(*$1, *$2); };
ident_list      : identifier { $$ = new VariableList(); $$->push_back($<var_decl>1); }
                | ident_list COMMA identifier { $1->push_back($<var_decl>3); };
type            : simple_type 
                | array_type;
simple_type     : INTEGER { $$ = new string(*$1); delete $1; } 
                | REAL { $$ = new string(*$1); delete $1; }
                | BOOLEAN { $$ = new string(*$1); delete $1; }
                | CHAR { $$ = new string(*$1); delete $1; }
                | LABEL { $$ = new string(*$1); delete $1; };
array_type      : ARRAY tamanho OF simple_type;
tamanho         : integer_constant;
proc_decl       : proc_header block_stmt { $$ = new NProcDeclaration(*$1, *$2);};
proc_header     : PROCEDURE identifier { $$ = new NProcHeader(*$2);} 
                | PROCEDURE identifier OPEN_PARENS formal_list CLOSE_PARENS { $$ = new NProcHeader(*$2, *$4); delete $4; };
formal_list     : parameter_decl { $$ = new VariableList(); $$->push_back($<var_decl>1); } 
                | formal_list SEMI_COLON parameter_decl { $1->push_back($<var_decl>3); };
parameter_decl  : parameter_type identifier;
parameter_type  : type 
                | proc_signature;
proc_signature  : PROCEDURE identifier OPEN_PARENS type_list CLOSE_PARENS 
                | PROCEDURE identifier;
type_list       : parameter_type 
                | type_list COMMA parameter_type;
stmt_list       : stmt { $$->statements.push_back($<stmt>1); }
                | stmt_list SEMI_COLON stmt { $$->statements.push_back($<stmt>3); };
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
variable        : identifier { $<ident>$ = $1; }
                | array_element;
array_element   : identifier OPEN_BRACK expression CLOSE_BRACK { $$ = new NArrayElem($1, $3); };
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
expr_list       : expression { $$ = new NExpressionStatement(*$1); } 
                | expr_list COMMA expression;
expression      : simple_expr 
                | simple_expr comparison simple_expr { $$ = new NBinaryOperator(*$1, $2, *$3); };
simple_expr     : term 
                | simple_expr ADDOP term { $$ = new NBinaryOperator(*$1, $2, *$3); };
term            : factor_a 
                | term MULOP factor_a { $$ = new NBinaryOperator(*$1, $2, *$3); };
factor_a        : factor 
                | NOT factor { $$ = new NUnaryOperator($1, *$2); }
                | SIGN factor { $$ = new NUnaryOperator($1, *$2); };
factor          : variable 
                | constant { $<string>$ = $1; }
                | OPEN_PARENS expression CLOSE_PARENS { $$ = new NExpressionStatement(*$2); };
constant        : integer_constant { $<string>$ = $1; }
                | real_constant { $<string>$ = $1; }
                | char_constant { $<string>$ = $1; }
                | boolean_constant { $<string>$ = $1; };
comparison      : RELOP;
boolean_constant: FALSE 
                | TRUE;
integer_constant: unsigned_integer;
unsigned_integer: DIGIT { $$ = new NInteger(atol($1->c_str())); delete $1; };
real_constant   : unsigned_real;
unsigned_real   : unsigned_integer DOT unsigned_integer scale_factor
                | unsigned_integer DOT unsigned_integer
                | unsigned_integer scale_factor
                | unsigned_integer { $$ = new NDouble(atof($1->c_str())); delete $1; };
scale_factor    : EXP SIGN unsigned_integer;
char_constant   : STRING;
identifier      : ID { $$ = new NIdentifier(*$1); delete $1; };
%%
