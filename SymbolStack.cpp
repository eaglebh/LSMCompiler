#include "SymbolStack.h"
#include <algorithm>
#include <iostream>

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

void SymbolStack::print(){
    std::cerr << "level nome\t\t" << "nivel\t" << "tipo" << std::endl;
    for (std::list<Symbol*>::iterator it = symbolList.begin();
            it != symbolList.end(); it++) {
            Symbol* s = *it;
        std::cerr << "level " << s->id << "\t\t" << s->level << '\t' << typeToString(s->type) << std::endl;
    }
}
