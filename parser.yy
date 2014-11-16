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
    #include <cstdarg>
    #include "struct/object.h"
    #include "struct/list.h"

    #include "scanner.h"

    #undef yylex
    #define yylex scanner.yylex

    void yyerror(const char * format, ...);

    #define yytext scanner.yylval

    extern SymbolStack *ts;
    extern SymbolStack *aux;
    extern SymbolStack *parameters;
    extern SymbolStack *labels;

    Symbol *symbol1 = NULL;
    Symbol *symbol2 = NULL;
    Symbol *symb_atr = NULL;
    Symbol *symb_proc = NULL;

    int nl = -1;
    int offset = 0;
    int nvars;        // variaveis locais
    int nparam;        // numero de parametros
    int label = 0;
    int write = 0;  // indica uso de write
    int read = 0;  // indica uso de read
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
%token <token>     IF WHILE DO LABEL
%token <token>     DECLARE END INTEGER REAL BOOLEAN CHAR ARRAY OF PROCEDURE THEN ELSE UNTIL FALSE TRUE
%token <token>      READ WRITE GOTO RETURN
%token <token>      NOT OR AND
%token <token>      ASSIGNOP
%token <token>      EQL NEQ LSS GTR LEQ GEQ PLUS MINUS TIMES DIV
%token <token>      COMMA SEMICOLON DOT LPAREN RPAREN LBRACKET RBRACKET COLON EXP
%token <string>     STRING

/* precedencia de operadores */
%left PLUS MINUS
%left TIMES DIV

/* if/else */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program         :
    PROGRAM
    {
        gen_code("\tINPP\n");
    }
    identifier
    {
        symbol1 = object_create(*yytext->string, nl, offset); aux->push(symbol1);
    }
    proc_body
    {
        gen_code("\tPARA\n");
    }
;

proc_body       : block_stmt ;

block_stmt:
    before_declare
    optional_declare
    DO
    stmt_list
    {
        nvars = 0;

        while ( (symbol1 = ts->top()) ) {
            if (symbol1->cat == C_PROCEDURE && symbol1->nl == nl) {
                break;
            }
            if (symbol1->nl != nl) {
                break;
            }

            ts->topPop();
            if (symbol1->cat == C_VARIABLE)
                nvars++;
        }
        if (nvars)
            gen_code("\tDMEM %d\n", nvars);
        if (symbol1) {
            gen_code("\tRTPR %d, %d\n", nl, symbol1->nParameter);
        }
        nl--;
    }
    END
;

before_declare : /* empty */ {nl++; } ;

optional_declare: /* empty */
                |DECLARE decl_list ;

decl_list   : decl
            | decl_list SEMICOLON decl ;

decl        :
            {
                while ( (symbol1 = aux->topPop()) );
                offset = 0;
            }
            variable_decl
            {
                gen_code("\tDSVS ");
                symbol1 = object_create_label(write_label());
                gen_code("\n");
                labels->push(symbol1);
            }
            |
            {
                nl++; offset = 0;
            }
            proc_decl
            {
                nl--;
                symbol1 = labels->topPop();
                if(symbol1)
                    gen_code("R%03d:\tNADA\n", symbol1->label);
            }
;

variable_decl:
    type ident_list
    {
        if (aux->size())
            gen_code("\tAMEM %d\n", aux->size());

        nvars = aux->size();
        while ( (symbol1 = aux->topPop()) ) {
            symbol1->cat = C_VARIABLE;
            ts->push(symbol1);
        }
    }
 ;

ident_list:
    identifier
    {
        if (symbol2 && symbol2->nl == nl) {
            yyerror("Variável já declarada.");
        }

        if (is_label) {
            symbol1 = object_create_label(label);
            label++;
            symbol1->id = *yytext->string;
            ts->push(symbol1);
        } else {
            symbol1 = object_create(*yytext->string, nl, offset);
            offset++;
            aux->push(symbol1);
        }
    }
    | ident_list COMMA
        identifier
        {
            if (symbol2 && symbol2->nl == nl)
                yyerror("Variável já declarada.");

            if (is_label) {
                symbol1 = object_create_label(label);
                label++;
                symbol1->id = *yytext->string;
                ts->push(symbol1);
            } else {
                symbol1 = object_create(*yytext->string, nl, offset);
                offset++;
                aux->push(symbol1);
            }
        }
;

type            : { is_label = 0; } simple_type
                | { is_label = 0; } array_type
;

simple_type     : INTEGER
                | REAL
                | BOOLEAN
                | CHAR
                | { is_label = 1; } LABEL
;

array_type      : ARRAY tamanho OF simple_type;

tamanho         : integer_constant;

proc_decl   : proc_header
            {nl--;}
            block_stmt
            {nl++;}
;

proc_header     :
    PROCEDURE
    {
        write_label();
        gen_code(":\tENPR %d\n", nl);
    }
    identifier
    {
        if (symbol1 && symbol1->nl == nl)
             yyerror("Procedimento já declarado.");

        symb_proc = object_create_procedure(*yytext->string);
        symb_proc->nl = nl;
        symb_proc->label = label - 1;
    }
    optional_proc_params
;

optional_proc_params: /* empty */
                    {
                        ts->push(symb_proc);
                        symb_proc = NULL;
                        offset = 0;
                    }
                    | LPAREN formal_list RPAREN
                    {
                        symb_proc->nParameter = parameters->size();
                        symb_proc->parameters = (int*)malloc(sizeof(int) * symb_proc->nParameter);
                        int i;

                        i = symb_proc->nParameter - 1;
                        offset = -4;
                        ts->push(symb_proc);
                        while ( (symbol1 = parameters->topPop()) ) {
                            symbol1->offset = offset;
                            offset--;
                            ts->push(symbol1);
                            symb_proc->parameters[i] = symbol1->passage;
                            i--;
                        }
                        symb_proc = NULL;
                        offset = 0;
                    }

formal_list     :
    parameter_decl
	{
        if (symbol2 && symbol2->nl == nl)
            yyerror("Variável já declarada.");
    }
    |
    formal_list SEMICOLON parameter_decl
    {
        if (symbol2 && symbol2->nl == nl)
            yyerror("Variável já declarada.");
    }
    ;

parameter_decl:
    parameter_type identifier
    {
        symbol1 = object_create(*yytext->string, nl, offset);
        offset++;
        aux->push(symbol1);

        symbol1->cat = C_PARAMETER;
        symbol1->passage = P_ADDRESS;
        parameters->push(symbol1);
    }
;

parameter_type  : type
                | proc_signature ;

proc_signature  : PROCEDURE identifier LPAREN type_list RPAREN
                | PROCEDURE identifier ;

type_list       : parameter_type
                | type_list COMMA parameter_type ;

stmt_list       : stmt
                | stmt_list SEMICOLON stmt ;

stmt            : identifier
                {
            //        symbol1 = list_find(ts, yytext);
                    symbol1->nl = nl;
                    if (symbol1) {
                        gen_code("R%03d:\tENRT %d %d\n", symbol1->label, nl, nvars);
                    } else {
                        yyerror("label não declarado.\n");
                    }
                } COLON unlabelled_stmt
                | unlabelled_stmt
;

label           : identifier;

unlabelled_stmt : assign_stmt
                    | if_stmt
                    |
                    {
                        symbol1 = object_create(std::string(""), 0, 0);
                        symbol1->label = write_label();
                        gen_code(":\tNADA\n");
                        labels->push(symbol1);
                    }
                    loop_stmt
                    | read_stmt
                    | write_stmt
                    | goto_stmt
                    | proc_stmt
                    | return_stmt
                    | block_stmt
;

assign_stmt     :
                variable
                {
                    symb_atr = object_cpy(symb_atr, symbol1);
                }
                ASSIGNOP expression
                {
                    if (!symb_atr)
                        yyerror("variable nao declarada.");

                    if (symb_atr->cat == C_PARAMETER && symb_atr->passage == P_ADDRESS) {
                        gen_code("\tARMI %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id.c_str());
                    } else
                        gen_code("\tARMZ %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id.c_str());
                }
;

variable:
    identifier
    | array_element
;

variable_list   :
    {
        if (read) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (read) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
        }
    }
    | variable_list COMMA
    {
        if (read) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (read) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
        }
    }
;

array_element   : identifier LBRACKET expression RBRACKET ;

if_stmt:
    IF condition
    THEN stmt_list
    {
        symbol1 = object_create(std::string(""), 0, 0);
        gen_code("\tDSVS ");
        symbol1->label = write_label();
        gen_code("\n");
        symbol2 = labels->topPop();
        gen_code("R%03d:\tNADA\n", symbol2->label);
        labels->push(symbol1);
    }
    %prec LOWER_THAN_ELSE
    {
        symbol1 = labels->topPop();
        gen_code("R%03d:\tNADA\n", symbol1->label);
    }
    END
    |
    IF condition
    THEN stmt_list
    {
        symbol1 = object_create(std::string(""), 0, 0);
        gen_code("\tDSVS ");
        symbol1->label = write_label();
        gen_code("\n");
        symbol2 = labels->topPop();
        gen_code("R%03d:\tNADA\n", symbol2->label);
        labels->push(symbol1);
    }
    ELSE stmt_list
    {
        symbol1 = labels->topPop();
        gen_code("R%03d:\tNADA\n", symbol1->label);
    }
    END
;

condition:
    expression
    {
        symbol1 = object_create(std::string(""), 0, 0);
        gen_code("\tDSVF ");
        symbol1->label = write_label();
        gen_code("\n");
        labels->push(symbol1);
    }
;

loop_stmt:  WHILE condition DO stmt_list
            {
                symbol1 = labels->topPop();
                symbol2 = labels->topPop();
                gen_code("\tDSVS r%02d\n", symbol2->label);
                gen_code("R%03d:\tNADA\n", symbol1->label);
            }
            END
            |
            DO stmt_list
            {
                symbol1 = labels->topPop();
                symbol2 = labels->topPop();
                gen_code("\tDSVS r%02d\n", symbol2->label);
                gen_code("R%03d:\tNADA\n", symbol1->label);
            }
            UNTIL condition;

read_stmt:
    READ
    {
        read = 1;
    }
    LPAREN variable_list RPAREN
    {
        read = 0;
    }
;

write_stmt:
    WRITE
    {
        write = 1;
    }
    LPAREN expr_list RPAREN
    {
        write = 0;
    }
;

goto_stmt:
    GOTO label
    {
        if (symbol1) {
            gen_code("\tDSVR r%02d, %d, %d\n", symbol1->label, symbol1->nl, nl);
        } else {
            yyerror("label não declarado.\n");
        }
    }
;

proc_stmt   :
            identifier
            {
                if (!symbol1)
                    yyerror("procedimento não declarado");

                symb_proc = object_cpy(symb_proc, symbol1);
                nparam = 0;
            }
            LPAREN expr_list RPAREN
            {
                gen_code("\tCHPR R%03d, %d\n", symb_proc->label, nl);
                symb_proc = NULL;
            }
            |
            identifier
            {
                if (!symbol1)
                    yyerror("procedimento não declarado");

                symb_proc = object_cpy(symb_proc, symbol1);
                nparam = 0;

                gen_code("\tCHPR R%03d, %d\n", symb_proc->label, nl);
                symb_proc = NULL;
            }
;

return_stmt     : RETURN;

expr_list:
    expression
    {
        if (write)
            gen_code("\tIMPR\n");
    }
    |
    expr_list COMMA
    expression
    {
        if (write)
            gen_code("\tIMPR\n");
    }
;


expression:
    simple_expr
    | simple_expr EQL simple_expr { gen_code("\tCMIG\n"); }
    | simple_expr NEQ simple_expr { gen_code("\tCMDG\n"); }
    | simple_expr LSS simple_expr { gen_code("\tCMME\n"); }
    | simple_expr GTR simple_expr { gen_code("\tCMMA\n"); }
    | simple_expr LEQ simple_expr { gen_code("\tCMEG\n"); }
    | simple_expr GEQ simple_expr { gen_code("\tCMAG\n"); }
;

simple_expr:
    term
    | simple_expr PLUS  term { gen_code("\tSOMA\n"); }
    | simple_expr MINUS term { gen_code("\tSUBT\n"); }
    | simple_expr OR    term { gen_code("\tDISJ\n"); }
;

term:
    factor_a
    | term TIMES factor_a { gen_code("\tMULT\n"); }
    | term DIV   factor_a { gen_code("\tDIVI\n"); }
    | term AND   factor_a { gen_code("\tCONJ\n"); }
;

factor_a:   factor
            | NOT factor { gen_code("\tNEGA\n"); }
            | PLUS factor
            | MINUS factor { gen_code("\tINVR\n"); }

;

factor:
    variable
    {
//        symbol1 = list_find(ts, yytext);
        if (!symbol1)
            yyerror("variável não declarada %s.", yytext->string->c_str());

        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento %s chamado com número inválido de parâmetros %d de %d.", symb_proc->id.c_str(), nparam, symb_proc->nParameter);

        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS) {
            if (symbol1->cat == C_VARIABLE) {
                gen_code("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
            }else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE) {
                    gen_code("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
                } else {
                    if (symbol1->passage == P_ADDRESS) {
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
                    }
                }
            }
            nparam++;
        } else {
            if (symbol1->cat == C_VARIABLE){
                gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
            } else {
                if (symbol1->cat == C_PARAMETER) {
                    if (symbol1->passage == P_VALUE){
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
                    } else {
                        if (symbol1->passage == P_ADDRESS) {
                            gen_code("\tCRVI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id.c_str());
                        }
                    }
                }
            }
        }
    }
    | constant
    {
        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS)
            yyerror("parâmetro inteiro passado por referência.");
        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento chamado com número inválido de parâmetros.");

        gen_code("\tCRCT %s\n", const_value);
    }
    | LPAREN expression RPAREN
;

constant        : integer_constant
                | real_constant
                | char_constant
                | boolean_constant ;

boolean_constant: FALSE { const_value = strdup("0"); }
                | TRUE { const_value = strdup("1"); } ;

integer_constant: unsigned_integer ;

unsigned_integer: UINT { const_value = strdup(yytext->string->c_str()); const_number = strtol(const_value, NULL, 10); } ;

real_constant   : unsigned_real;

unsigned_real   :   unsigned_integer
                    DOT
                    {
                        integer_part = const_number;
                    }
                    unsigned_integer
                    {
                        fractional_part = const_number;
                        fractional_part_length = strlen(const_value);
                        coefficient = integer_part + (fractional_part/(10^fractional_part_length));
                        exponent = 0;
                    }
                    optional_scale_factor
                    {
                        const_value = (char*)malloc(MAXNUMSTR*sizeof(char));
                        snprintf(const_value, MAXNUMSTR, "%d", coefficient*(10^exponent));
                    }
                |   unsigned_integer
                    {
                        coefficient = const_number;
                    }
                    scale_factor
                    {
                        const_value = (char*)malloc(MAXNUMSTR*sizeof(char));
                        snprintf(const_value, MAXNUMSTR, "%d", coefficient*(10^exponent));
                    }
;

optional_scale_factor:
                        |   scale_factor
                            {
                                const_value = (char*)malloc(MAXNUMSTR*sizeof(char));
                                snprintf(const_value, MAXNUMSTR, "%d", coefficient*(10^exponent));
                            }

scale_factor    : "E" PLUS unsigned_integer { exponent = const_number; }
                | "E" MINUS unsigned_integer { exponent = -const_number; } ;

char_constant   : STRING { const_value = strdup(yytext->string->c_str()); } ;

identifier:
    ID
    {
        symbol1 = ts->find(*yytext->string);
        symbol2 = aux->find(*yytext->string);
    }
;

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
