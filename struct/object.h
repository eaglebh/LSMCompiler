#ifndef _object_
#define _object_
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PARAMETERS 64
#define MAX_ID_SIZE 64

#define C_VARIABLE 0
#define C_PARAMETER 1
#define C_PROCEDURE 2
#define C_FUNCTION 3
#define C_LABEL 4

#define P_VALUE 0
#define P_ADDRESS 1

class Symbol {
public:
    char id[MAX_ID_SIZE];
    int nl;
    int offset;
    int label;
    int cat;
    int passage;
    int nParameter;
    int *parameters;
};

Symbol* object_create(char *id, int nl, int offset);
Symbol* object_create_procedure(char *id);
Symbol* object_create_function(char *id);
Symbol* object_create_label(int label);
Symbol* object_cpy(Symbol *object1, Symbol *object2);
void object_write(void *p);
void object_destroy(Symbol *object);
int object_cmp_id(Symbol *object1, Symbol *object2);
int object_cmp_nl(Symbol *object1, Symbol *object2);
int object_cmp(Symbol *object1, Symbol *object2);

#endif

