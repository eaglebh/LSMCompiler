#include "SymbolStack.h"
#include <algorithm>

Symbol *SymbolStack::topPop() {
    if (symbolStack.empty())
        return NULL;
    Symbol *node = top();
    symbolStack.pop();
    return node;
}

Symbol* SymbolStack::find(const std::string id){
    Symbol* aux = NULL;
    for (std::list<Symbol*>::iterator it = symbolList.begin();
            it != symbolList.end(); it++) {
        if((*it)->id == id)
            if((aux == NULL) || ((*it)->level > aux->level))
                aux = *it;
    }
    return aux;
}
