#ifndef _SymbolH_
#define _SymbolH_
#include <string>

#define MAX_PARAMETERS 64

#define C_VARIABLE 0
#define C_PARAMETER 1
#define C_PROCEDURE 2
#define C_LABEL 3

#define P_VALUE 0
#define P_ADDRESS 1

enum TypeEnum {
    voidType = 0,
    integerType = 1,
    realType,
    booleanType,
    charType,
    labelType,
    stringType
};

class Symbol {
public:
    std::string id;
    int level;
    int offset;
    int label;
    int category;
    TypeEnum type;
    int passage;
    int nParameter;
    int *parameters;

    Symbol() {
        id = std::string("");
        level = 0;
        offset = 0;
        label = 0;
        category = 0;
        type = voidType;
        passage = P_ADDRESS;
        nParameter = 0;
        parameters = NULL;
    }
};

Symbol* buildSymbol(std::string id, int level, int offset);
Symbol* buildProcedure(std::string id);
Symbol* buildLabel(int label);
Symbol* copySymbol(Symbol *object1, Symbol *object2);

std::string typeToString(TypeEnum type);

#endif
