#ifndef _SymbolStackH_
#define _SymbolStackH_
#include <stack>
#include <list>
#include "Symbol.h"

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
            if (!symbolStack.empty()) {
                symbolStack.pop();
                symbolList.pop_back();
            }
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
        void print();

    private:
        std::stack<Symbol*> symbolStack;
        std::list<Symbol*> symbolList;
};

#endif
