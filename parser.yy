%skeleton "lalr1.cc"
%defines
%define parser_class_name {LSMParser}

%code requires{
    class LSMScanner;

    #include "struct/object.h"
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

    SymbolStack *symbolTable = new SymbolStack();
    SymbolStack *auxTable = new SymbolStack();
    SymbolStack *parameters = new SymbolStack();
    SymbolStack *labels = new SymbolStack();

    Symbol *symbol1 = NULL;
    Symbol *symbol2 = NULL;
    Symbol *assignedSymbol = NULL;
    Symbol *procedureSymbol = NULL;

    int level = -1;
    int offset = 0;
    int varsNumber;      // numero de variaveis locais
    int paramsNumber;     // numero de parametros de procedimentos
    int label = 0;
    int parsingWrite = 0;  // indica uso de write
    int parsingRead = 0;   // indica uso de read
    int isLabel = 0;
    t_types current_type = voidType;

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
    t_types type;
}

%start program
%token PROGRAM
%token UNKNOWN
%token <uint_type>  UINT
%token <string>     ID
%token <token>      IF WHILE DO LABEL
%token <token>      DECLARE END INTEGER REAL BOOLEAN CHAR ARRAY OF PROCEDURE THEN ELSE UNTIL FALSE TRUE
%token <token>      READ WRITE GOTO RETURN
%token <token>      NOT OR AND
%token <token>      ASSIGNOP
%token <token>      EQL NEQ LSS GTR LEQ GEQ PLUS MINUS TIMES DIV
%token <token>      COMMA SEMICOLON DOT LPAREN RPAREN LBRACKET RBRACKET COLON EXP
%token <string>     STRING

%type <type> condition expression simple_expr term factor_a factor variable constant

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
        symbol1 = object_create(*yytext->string, level, offset); auxTable->push(symbol1);
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
        varsNumber = 0;

        while ( (symbol1 = symbolTable->top()) ) {
            if (symbol1->cat == C_PROCEDURE && symbol1->level == level) {
                break;
            }
            if (symbol1->level != level) {
                break;
            }

            symbolTable->topPop();
            if (symbol1->cat == C_VARIABLE)
                varsNumber++;
        }
        if (varsNumber)
            gen_code("\tDMEM %d\n", varsNumber);
        if (symbol1) {
            gen_code("\tRTPR %d, %d\n", level, symbol1->nParameter);
        }
        level--;
    }
    END
;

before_declare : /* empty */ {level++; } ;

optional_declare: /* empty */
                |DECLARE decl_list ;

decl_list   : decl
            | decl_list SEMICOLON decl ;

decl        :
            {
                while ( (symbol1 = auxTable->topPop()) );
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
                level++; offset = 0;
            }
            proc_decl
            {
                level--;
                symbol1 = labels->topPop();
                if(symbol1)
                    gen_code("R%03d:\tNADA\n", symbol1->label);
            }
;

variable_decl:
    type ident_list
    {
        if (auxTable->size())
            gen_code("\tAMEM %d\n", auxTable->size());

        varsNumber = auxTable->size();
        while ( (symbol1 = auxTable->topPop()) ) {
            symbol1->cat = C_VARIABLE;
            symbol1->type = current_type;
            symbolTable->push(symbol1);
        }
    }
 ;

ident_list:
    identifier
    {
        if (symbol2 && symbol2->level == level) {
            yyerror("Variável já declarada.");
        }

        if (isLabel) {
            symbol1 = object_create_label(label);
            label++;
            symbol1->id = *yytext->string;
            symbolTable->push(symbol1);
        } else {
            symbol1 = object_create(*yytext->string, level, offset);
            offset++;
            auxTable->push(symbol1);
        }
    }
    | ident_list COMMA
        identifier
        {
            if (symbol2 && symbol2->level == level)
                yyerror("Variável já declarada.");

            if (isLabel) {
                symbol1 = object_create_label(label);
                label++;
                symbol1->id = *yytext->string;
                symbolTable->push(symbol1);
            } else {
                symbol1 = object_create(*yytext->string, level, offset);
                offset++;
                auxTable->push(symbol1);
            }
        }
;

type            : { isLabel = 0; current_type = voidType; } simple_type
                | { isLabel = 0; current_type = voidType; } array_type
;

simple_type     : INTEGER { current_type = integerType; }
                | REAL { current_type = realType; }
                | BOOLEAN { current_type = booleanType; }
                | CHAR { current_type = charType; }
                | { isLabel = 1; } LABEL { current_type = labelType; }
;

array_type      : ARRAY tamanho OF simple_type;

tamanho         : integer_constant;

proc_decl   : proc_header
            {level--;}
            block_stmt
            {level++;}
;

proc_header     :
    PROCEDURE
    {
        write_label();
        gen_code(":\tENPR %d\n", level);
    }
    identifier
    {
        if (symbol1 && symbol1->level == level)
             yyerror("Procedimento já declarado.");

        procedureSymbol = object_create_procedure(*yytext->string);
        procedureSymbol->level = level;
        procedureSymbol->label = label - 1;
    }
    optional_proc_params
;

optional_proc_params: /* empty */
                    {
                        symbolTable->push(procedureSymbol);
                        procedureSymbol = NULL;
                        offset = 0;
                    }
                    | LPAREN formal_list RPAREN
                    {
                        procedureSymbol->nParameter = parameters->size();
                        procedureSymbol->parameters = (int*)malloc(sizeof(int) * procedureSymbol->nParameter);
                        int i;

                        i = procedureSymbol->nParameter - 1;
                        offset = -4;
                        symbolTable->push(procedureSymbol);
                        while ( (symbol1 = parameters->topPop()) ) {
                            symbol1->offset = offset;
                            offset--;
                            symbolTable->push(symbol1);
                            procedureSymbol->parameters[i] = symbol1->passage;
                            i--;
                        }
                        procedureSymbol = NULL;
                        offset = 0;
                    }

formal_list     :
    parameter_decl
	{
        if (symbol2 && symbol2->level == level)
            yyerror("Variável já declarada.");
    }
    |
    formal_list SEMICOLON parameter_decl
    {
        if (symbol2 && symbol2->level == level)
            yyerror("Variável já declarada.");
    }
    ;

parameter_decl:
    parameter_type identifier
    {
        symbol1 = object_create(*yytext->string, level, offset);
        offset++;
        auxTable->push(symbol1);

        symbol1->cat = C_PARAMETER;
        symbol1->type = current_type;
        symbol1->passage = P_ADDRESS;
        parameters->push(symbol1);
    }
;

parameter_type  : type
                | proc_signature { current_type = voidType; };

proc_signature  : PROCEDURE identifier LPAREN type_list RPAREN
                | PROCEDURE identifier ;

type_list       : parameter_type
                | type_list COMMA parameter_type ;

stmt_list       : stmt
                | stmt_list SEMICOLON stmt ;

stmt            : identifier
                {
            //        symbol1 = list_find(symbolTable, yytext);
                    symbol1->level = level;
                    if (symbol1) {
                        gen_code("R%03d:\tENRT %d %d\n", symbol1->label, level, varsNumber);
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
                    assignedSymbol = object_cpy(assignedSymbol, symbol1);
                }
                ASSIGNOP expression
                {
                    if (!assignedSymbol)
                        yyerror("variavel nao declarada.");

                    if (assignedSymbol->cat == C_PARAMETER) {
                        gen_code("\tARMI %d, %d # %s\n", assignedSymbol->level, assignedSymbol->offset, assignedSymbol->id.c_str());
                    } else {
                        gen_code("\tARMZ %d, %d # %s\n", assignedSymbol->level, assignedSymbol->offset, assignedSymbol->id.c_str());
                    }
                    //std::cerr << "var = " << $1 << " expr = " << $3 << " st = " << assignedSymbol->type << std::endl;
                }
;

variable:
    identifier { $$ = symbol1->type; }
    | array_element { $$ = symbol1->type; }
;

variable_list   :
    {
        if (parsingRead) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (parsingRead) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
        }
    }
    | variable_list COMMA
    {
        if (parsingRead) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (parsingRead) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
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
        $$ = $1;
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
        parsingRead = 1;
    }
    LPAREN variable_list RPAREN
    {
        parsingRead = 0;
    }
;

write_stmt:
    WRITE
    {
        parsingWrite = 1;
    }
    LPAREN expr_list RPAREN
    {
        parsingWrite = 0;
    }
;

goto_stmt:
    GOTO label
    {
        if (symbol1) {
            gen_code("\tDSVR r%02d, %d, %d\n", symbol1->label, symbol1->level, level);
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

                procedureSymbol = object_cpy(procedureSymbol, symbol1);
                paramsNumber = 0;
            }
            LPAREN expr_list RPAREN
            {
                gen_code("\tCHPR R%03d, %d\n", procedureSymbol->label, level);
                procedureSymbol = NULL;
            }
            |
            identifier
            {
                if (!symbol1)
                    yyerror("procedimento não declarado");

                procedureSymbol = object_cpy(procedureSymbol, symbol1);
                paramsNumber = 0;

                gen_code("\tCHPR R%03d, %d\n", procedureSymbol->label, level);
                procedureSymbol = NULL;
            }
;

return_stmt     : RETURN;

expr_list:
    expression
    {
        if (parsingWrite)
            gen_code("\tIMPR\n");
    }
    |
    expr_list COMMA
    expression
    {
        if (parsingWrite)
            gen_code("\tIMPR\n");
    }
;


expression:
    simple_expr {  $$ = $1; }
    | simple_expr EQL simple_expr { gen_code("\tCMIG\n"); $$ = booleanType; }
    | simple_expr NEQ simple_expr { gen_code("\tCMDG\n"); $$ = booleanType; }
    | simple_expr LSS simple_expr { gen_code("\tCMME\n"); $$ = booleanType; }
    | simple_expr GTR simple_expr { gen_code("\tCMMA\n"); $$ = booleanType; }
    | simple_expr LEQ simple_expr { gen_code("\tCMEG\n"); $$ = booleanType; }
    | simple_expr GEQ simple_expr { gen_code("\tCMAG\n"); $$ = booleanType; }
;

simple_expr:
    term { $$ = $1; }
    | simple_expr PLUS  term
        {
            gen_code("\tSOMA\n");
            if ( $1 != realType && $1 != integerType) {
                error("Tipo inválido para operação de subtração lado esquerdo " + t_type2str($1));
            }
            if ( $3 != realType && $3 != integerType) {
                error("Tipo inválido para operação de subtração lado direto " + t_type2str($3));
            }
            if ($1 == realType || $3 == realType) {
                $$ = realType;
            } else {
                $$ = integerType;
            }
        }
    | simple_expr MINUS term
        {
            gen_code("\tSUBT\n");
            if ( $1 != realType && $1 != integerType) {
                error("Tipo inválido para operação de subtração lado esquerdo " + t_type2str($1));
            }
            if ( $3 != realType && $3 != integerType) {
                error("Tipo inválido para operação de subtração lado direto " + t_type2str($3));
            }
            if ($1 == realType || $3 == realType) {
                $$ = realType;
            } else {
                $$ = integerType;
            }
        }
    | simple_expr OR    term
        {
            gen_code("\tDISJ\n");
            if ( $1 != booleanType && $1 != integerType) {
                error("Tipo inválido para operação booleana \"or\" lado esquerdo " + t_type2str($1));
            }
            if ( $3 != booleanType && $3 != integerType) {
                error("Tipo inválido para operação booleana \"or\" lado direto " + t_type2str($3));
            }
            $$ = booleanType;
        }
;

term:
    factor_a { $$ = $1; }
    | term TIMES factor_a
        {
            gen_code("\tMULT\n");
            if ( $1 != realType && $1 != integerType) {
                error("Tipo inválido para operação de multiplicação lado esquerdo " + t_type2str($1));
            }
            if ( $3 != realType && $3 != integerType) {
                error("Tipo inválido para operação de multiplicação lado direto " + t_type2str($3));
            }
            if ($1 == realType || $3 == realType) {
                $$ = realType;
            } else {
                $$ = integerType;
            }
        }
    | term DIV   factor_a
        {
            gen_code("\tDIVI\n");
            if ( $1 != realType && $1 != integerType) {
                error("Tipo inválido para operação de divisão lado esquerdo " + t_type2str($1));
            }
            if ( $3 != realType && $3 != integerType) {
                error("Tipo inválido para operação de divisão lado direto " + t_type2str($3));
            }
            if ($1 == realType || $3 == realType) {
                $$ = realType;
            } else {
                $$ = integerType;
            }
        }
    | term AND   factor_a
        {
            gen_code("\tCONJ\n");
            if ( $1 != booleanType && $1 != integerType) {
                error("Tipo inválido para operação booleana \"and\" lado esquerdo " + t_type2str($1));
            }
            if ( $3 != booleanType && $3 != integerType) {
                error("Tipo inválido para operação booleana \"and\" lado direto " + t_type2str($3));
            }
            $$ = booleanType;
        }
;

factor_a:   factor { $$ = $1;}
            | NOT factor
                {
                    gen_code("\tNEGA\n");
                    if ( $2 != booleanType && $2 != integerType) {
                        error("Tipo inválido para operação booleana " + t_type2str($2));
                    }
                    $$ = booleanType;
                }
            | PLUS factor
                {
                    if ( $2 != realType && $2 != integerType) {
                        error("Tipo inválido para operação unária " + t_type2str($2));
                    }
                    $$ = $2;
                }
            | MINUS factor
                {
                    gen_code("\tINVR\n");
                    if ( $2 != realType && $2 != integerType) {
                        error("Tipo inválido para operação unária " + t_type2str($2));
                    }
                    $$ = $2;
                }
;

factor:
    variable
    {
//        symbol1 = list_find(symbolTable, yytext);
        if (!symbol1)
            yyerror("variável não declarada %s.", yytext->string->c_str());

        if (procedureSymbol && paramsNumber >= procedureSymbol->nParameter)
            yyerror("procedimento %s chamado com número inválido de parâmetros %d de %d.", procedureSymbol->id.c_str(), paramsNumber, procedureSymbol->nParameter);

        if (procedureSymbol && procedureSymbol->parameters[paramsNumber] == P_ADDRESS) {
            if (symbol1->cat == C_VARIABLE) {
                gen_code("\tCREN %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
            }else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE) {
                    gen_code("\tCREN %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
                } else {
                    if (symbol1->passage == P_ADDRESS) {
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
                    }
                }
            }
            paramsNumber++;
        } else {
            if (symbol1->cat == C_VARIABLE){
                gen_code("\tCRVL %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
            } else {
                if (symbol1->cat == C_PARAMETER) {
                    if (symbol1->passage == P_VALUE){
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
                    } else {
                        if (symbol1->passage == P_ADDRESS) {
                            gen_code("\tCRVI %d, %d # %s\n", symbol1->level, symbol1->offset, symbol1->id.c_str());
                        }
                    }
                }
            }
        }
        $$ = symbol1->type;
    }
    | constant
    {
        if (procedureSymbol && procedureSymbol->parameters[paramsNumber] == P_ADDRESS)
            yyerror("parâmetro inteiro passado por referência.");
        if (procedureSymbol && paramsNumber >= procedureSymbol->nParameter)
            yyerror("procedimento chamado com número inválido de parâmetros.");

        gen_code("\tCRCT %s\n", const_value);
        $$ = $1;
    }
    | LPAREN expression RPAREN {  $$ = $2; }
;

constant        : integer_constant { $$ = integerType; }
                | real_constant { $$ = realType; }
                | char_constant { $$ = charType; };
                | boolean_constant { $$ = integerType; };

boolean_constant: FALSE { const_value = strdup("0"); }
                | TRUE { const_value = strdup("1"); } ;

integer_constant: unsigned_integer ;

unsigned_integer: UINT { const_value = strdup(yytext->string->c_str()); const_number = strtol(const_value, NULL, 10);} ;

real_constant   : unsigned_real ;

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
        symbol1 = symbolTable->find(*yytext->string);
        symbol2 = auxTable->find(*yytext->string);
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
