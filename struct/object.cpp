#include "object.h"

Symbol *object_create(std::string id, int level, int offset) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->id = id;
    o->level = level;
    o->offset = offset;
    return o;
}

Symbol *object_create_procedure(std::string id) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->id = id;
    o->cat = C_PROCEDURE;
    o->type = voidType;
    return o;
}

Symbol *object_create_label(int label) {
    Symbol *o = new Symbol;
    if(!o) return NULL;
    o->label = label;
    o->cat = C_LABEL;
    o->type = labelType;
    return o;
}

Symbol *object_cpy(Symbol *object1, Symbol *object2) {
    if(!object1)
        object1 = new Symbol;
    if(!object1 || !object2)
        return NULL;

    object1->id = object2->id;
    object1->level = object2->level;
    object1->offset = object2->offset;
    object1->cat = object2->cat;
    object1->type = object2->type;
    object1->passage = object2->passage;
    object1->nParameter = object2->nParameter;
    object1->parameters = object2->parameters;

    object1->label = object2->label;
    return object1;
}

std::string t_type2str(t_types type) {
    switch (type) {
    case integerType:
        return "integer";
    case realType:
        return "real";
    case booleanType:
        return "boolean";
    case charType:
        return "char";
    case labelType:
        return "label";
    case stringType:
        return "string";
    case voidType:
    default:
        return "void";
    }
}

