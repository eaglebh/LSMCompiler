#ifndef _list_
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stack>
#include <list>
#include "object.h"
#define _list_

class SymbolStack {
    public:
        Symbol* find(const std::string text);
        Symbol* topPop();
        SymbolStack(){};
        void push(Symbol* obj) {
            symbolStack.push(obj);
            symbolList.push_back(obj);
        };
        void pop() {
            if (!symbolStack.empty())
                symbolStack.pop();
        };
        Symbol* top() {
            if (symbolStack.empty())
                return NULL;

            return symbolStack.top();
        };
        std::stack<Symbol*>::size_type size() const {
            if (symbolStack.empty())
                return 0;
            return symbolStack.size();
        };

    private:
        std::stack<Symbol*> symbolStack;
        std::list<Symbol*> symbolList;
};

#endif
