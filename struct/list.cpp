#include "list.h"
#include <algorithm>

Symbol *SymbolStack::topPop() {
    if (symbolStack.empty())
        return NULL;
    Symbol *node = top();
    symbolStack.pop();
    return node;
}

Symbol* SymbolStack::find(const std::string text){
    //std::list<t_object*>::iterator findIter = std::find(symbolList.begin(), symbolList.end(), 1);

    Symbol* aux = NULL;
    for (std::list<Symbol*>::iterator it = symbolList.begin(); it != symbolList.end(); it++) {
        if((*it)->id == text)
            if((aux == NULL) || ((*it)->nl > aux->nl))
                aux = *it;
    }
    return aux;
}
