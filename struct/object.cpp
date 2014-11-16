#include "object.h"

Symbol *object_create(std::string id, int nl, int offset) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->id = id;
    o->nl = nl;
    o->offset = offset;
    return o;
}

Symbol *object_create_procedure(std::string id) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->id = id;
    o->cat = C_PROCEDURE;
    return o;
}

Symbol *object_create_function(std::string id) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->id = id;
    o->cat = C_FUNCTION;
    return o;
}

Symbol *object_create_label(int label) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->label = label;
    o->cat = C_LABEL;
    return o;
}

Symbol *object_cpy(Symbol *object1, Symbol *object2) {
    if(!object1)
        object1 = new Symbol;
    if(!object1 || !object2)
        return NULL;

    object1->id = object2->id;
    object1->nl = object2->nl;
    object1->offset = object2->offset;
    object1->cat = object2->cat;
    object1->passage = object2->passage;
    object1->nParameter = object2->nParameter;
    object1->parameters = object2->parameters;

    object1->label = object2->label;
    return object1;
}


