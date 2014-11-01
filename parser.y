

%{
    #include <stdio.h>
    #include <ctype.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include "compilador.h"
    #include "tabelasimb.h"
    #include "pilha.h"
    #include "aux.h"
    #include "trataerro.h"

    int num_vars, nivel_lexico, deslocamento, cont_rotulo, *temp_num, indice_param, teste=0;
    char *rotulo_mepa, *rotulo_mepa_aux;
    SimboloT *simb, *simb_aux, *proc_atual;

    TabelaSimbT *tab, tabelaSimbDin;
    PilhaT pilha_rot, pilha_tipos, pilha_amem_dmem, pilha_simbs;

    bool chamada_de_proc;
    TipoT tipo_aux;
    
    #define empilhaAMEM(n_vars) \
	temp_num = (int*)malloc (sizeof (int)); \
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

%}

%start program
%token PROGRAM
%token UNKNOWN
%token UINT
%token ID
%token IF WHILE DO LABEL
%token DECLARE END INTEGER REAL BOOLEAN CHAR ARRAY OF PROCEDURE THEN ELSE UNTIL FALSE TRUE
%token READ WRITE GOTO RETURN
%token NOT OR AND
%token ASSIGNOP
%token RELOP ADDOP MULOP
%token DIGIT LETTER
%token COMMA SEMI_COLON DOT OPEN_PARENS CLOSE_PARENS OPEN_BRACK CLOSE_BRACK TWO_DOTS 
%token EXP STRING

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
decl            : variable_decl { empilhaAMEM(deslocamento);
                                            geraRotulo(&rotulo_mepa, &cont_rotulo, &pilha_rot);
                                            geraCodigoArgs (NULL, "DSVS %s", rotulo_mepa); }
                | proc_decl { geraCodigo ((char*)desempilha(&pilha_rot), "NADA"); };
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
assign_stmt     : variable ASSIGNOP expression ;
variable        : identifier 
                | array_element ;
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
expression      : simple_expr 
		| simple_expr comparison simple_expr ;
simple_expr     : term 
                | simple_expr ADDOP term;
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
unsigned_integer: UINT ;
real_constant   : unsigned_real;
unsigned_real   : unsigned_integer DOT unsigned_integer scale_factor
                | unsigned_integer DOT unsigned_integer
                | unsigned_integer scale_factor ;
scale_factor    : "E" ADDOP unsigned_integer;
char_constant   : STRING  ;
identifier      : ID  ;
%%


int main (int argc, char** argv) {
  FILE* fp;
  extern FILE* yyin;

  if (argc<2 || argc>2) {
    printf("usage compilador <arq>a %d\n", argc);
    return(-1);
  }

  fp=fopen (argv[1], "r");
  if (fp == NULL) {
    printf("usage compilador <arq>b\n");
    return(-1);
  }

/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos Dinamica (pilha)
 * ------------------------------------------------------------------- */

  tab = &tabelaSimbDin;
  tab->num_simbolos = 0;
  tab->primeiro=tab->ultimo=NULL;
  inicializaPilha(&pilha_rot);
  inicializaPilha(&pilha_tipos);
  inicializaPilha(&pilha_simbs);

/* -------------------------------------------------------------------
 *  Inicializa as variaveis de controle
 * ------------------------------------------------------------------- */

  cont_rotulo = 0;

/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

  yyin=fp;
  yyparse();

#ifdef DEBUG
  // int i;
  // for (i=0; i<25; i++) {
  //   tipo_aux = *(TipoT *)(desempilha(&pilha_tipos));
  //   debug_print("[TipoT Tests] i=[%d].tipo_aux = %d\n", i, tipo_aux);
  // }

//  imprimeTabSimbolos(tab); // #DEBUG
//  atribuiTipoSimbTab(tab, "f1", T_REAL);   // #DEBUG
  imprimeTabSimbolos(tab); // #DEBUG

  // removeSimbolosTab(tab, "f1", 1);

  // imprimeTabSimbolos(tab); // #DEBUG
  printf("[Teste] teste = %d\n", teste); //#DEBUG
  desempilhaEImprime(&pilha_simbs);
#endif

  return 0;
}