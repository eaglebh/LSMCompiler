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
    
    #define empilhaAMEM(n_vars) \
	temp_num = malloc (sizeof (int)); \
	*temp_num = n_vars; \
	empilha(&pilha_amem_dmem, temp_num);
    
    
    #define geraCodigoDMEM() \
	num_vars = *(int *)desempilha(&pilha_amem_dmem); \
	if (num_vars) { \
	  geraCodigoArgs (NULL, "DMEM %d", num_vars);  \
	}
    

    #define geraCodigoARMZI(simbolo) \
	if (simbolo->passagem == T_VALOR) { geraCodigoArgs (NULL, "ARMZ %d, %d", simbolo->nivel_lexico, simbolo->deslocamento); } \
	else { geraCodigoArgs (NULL, "ARMI %d, %d", simbolo->nivel_lexico, simbolo->deslocamento); }


    #define geraCodigoCRxx(instrucao, simbolo) \
	geraCodigoArgs (NULL, "%s %d, %d", instrucao, simbolo->nivel_lexico, simbolo->deslocamento);

    #define geraCodigoCarregaValor(simbolo) \
	debug_print("[geraCodigoCarregaValor] simbolo->id = '%s', indice_param=%d, chamada_de_proc=%d\n", simbolo->id, indice_param, chamada_de_proc); \
	if (chamada_de_proc) { teste++;\
	    if (proc_atual != NULL) { \
		if ((proc_atual->lista_param[indice_param].passagem == T_REFERENCIA) && (simbolo->passagem == 		T_VALOR)) { geraCodigoCRxx("CREN", simbolo); } \
		else { geraCodigoCRxx("CRVL", simbolo); } }\
	    else { geraCodigoCRxx("CRVL", simbolo); } } \
	else if (simbolo->passagem == T_VALOR) { geraCodigoArgs (NULL, "CRVL %d, %d", simbolo->nivel_lexico, simbolo->deslocamento); } \
	  else { geraCodigoCRxx("CRVI", simbolo); }

    #define geraCodigoLEIT() \
	geraCodigo (NULL, "LEIT"); simb = procuraSimboloTab(tab, token, nivel_lexico); \
	    geraCodigoARMZI(simb);
    #define geraCodigoIMPR() \
	simb = procuraSimboloTab(tab, token, nivel_lexico); \
	    geraCodigoCarregaValor(simb); \
		geraCodigo (NULL, "IMPR");
    #define geraCodigoENPR(categoria) \
	geraRotulo(&rotulo_mepa, &cont_rotulo, &pilha_rot); \
	    geraCodigoArgs (desempilha(&pilha_rot), "ENPR %d", ++nivel_lexico); \
		simb = insereSimboloTab(tab, token, categoria, nivel_lexico); \
		    simb->rotulo = rotulo_mepa; \
			empilha(&pilha_simbs, simb); \
			    simb->num_parametros=num_vars = 0;
    #define desempilhaEImprime(pilha) \
	while ((simb = desempilhaMesmoNULL(pilha))) { debug_print("[desempilhaEImprime] simb->id = '%s'\n", simb->id); }

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
%token <token>      RELOP ADDOP MULOP
%token <string>     DIGIT LETTER
%token <token>      COMMA SEMI_COLON DOT OPEN_PARENS CLOSE_PARENS OPEN_BRACK CLOSE_BRACK TWO_DOTS 
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
stmt            : identifier TWO_DOTS unlabelled_stmt 
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
array_element   : identifier OPEN_BRACK expression CLOSE_BRACK ;
if_stmt         : IF condition THEN stmt_list END    
                | IF condition THEN stmt_list ELSE stmt_list END;
condition       : expression;
loop_stmt       : WHILE condition DO stmt_list END
		| DO stmt_list UNTIL condition;
read_stmt       : READ OPEN_PARENS ident_list CLOSE_PARENS;
write_stmt      : WRITE OPEN_PARENS expr_list CLOSE_PARENS;
goto_stmt       : GOTO label;
proc_stmt       : identifier OPEN_PARENS expr_list CLOSE_PARENS 
                | identifier;
return_stmt     : RETURN;
expr_list       : expression  
                | expr_list COMMA expression;
expression      : simple_expr {printf("simple_expr1");}
		| simple_expr {printf("simple_expr2");} comparison {printf("comparison");} simple_expr {printf("simple_expr2.1");} ;
simple_expr     : term {printf("term");}
                | simple_expr {printf("simple_expr4");} ADDOP term;
term            : factor_a 
                | term MULOP factor_a ;
factor_a        : factor 
                | NOT factor 
                | ADDOP factor ;
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
unsigned_integer: UINT { printf("[uint=%s]",yylhs.value.string->c_str()); };
real_constant   : unsigned_real;
unsigned_real   : unsigned_integer DOT unsigned_integer scale_factor
                | unsigned_integer DOT unsigned_integer
                | unsigned_integer scale_factor ;
scale_factor    : "E" ADDOP unsigned_integer;
char_constant   : STRING  ;
identifier      : ID { printf("[id=%s]",yylhs.value.string->c_str()); } ;
%%

void yy::LSMParser::error( const std::string &err_message )
{
    std::cerr << "Error: " << err_message << "\n";
}

