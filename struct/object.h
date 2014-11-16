#ifndef _objectH_
#define _objectH_
#include <cstdio>
#include <cstdlib>
#include <string>

#define MAX_PARAMETERS 64

#define C_VARIABLE 0
#define C_PARAMETER 1
#define C_PROCEDURE 2
#define C_FUNCTION 3
#define C_LABEL 4

#define P_VALUE 0
#define P_ADDRESS 1

enum t_types {
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
    int nl;
    int offset;
    int label;
    int cat;
    t_types type;
    int passage;
    int nParameter;
    int *parameters;

    Symbol() {
        id = std::string("");
        nl = 0;
        offset = 0;
        label = 0;
        cat = 0;
        type = voidType;
        passage = 0;
        nParameter = 0;
        parameters = NULL;
    }
};

Symbol* object_create(std::string id, int nl, int offset);
Symbol* object_create_procedure(std::string id);
Symbol* object_create_function(std::string id);
Symbol* object_create_label(int label);
Symbol* object_cpy(Symbol *object1, Symbol *object2);

std::string t_type2str(t_types type);

#endif

