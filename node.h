#include <iostream>
#include <vector>
//#include <llvm/Value.h>

class CodeGenContext;
class NStatement;
class NExpression;
class NVariableDeclaration;

typedef std::vector<NStatement*> StatementList;
typedef std::vector<NExpression*> ExpressionList;
typedef std::vector<NVariableDeclaration*> VariableList;

class Node {
public:
    virtual ~Node() {}
//    virtual llvm::Value* codeGen(CodeGenContext& context) { }
};

class NExpression : public Node {
};

class NStatement : public Node {
};

class NArrayElem : public NExpression {
public:
    const NIdentifier& id;
    NExpression &value;
    NArrayElem(const NIdentifier& id, NExpression &value) : id(id), value(value) { }
//    virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NInteger : public NExpression {
public:
    long long value;
    NInteger(long long value) : value(value) { }
//    virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NDouble : public NExpression {
public:
    double value;
    NDouble(double value) : value(value) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NIdentifier : public NExpression {
public:
    std::string name;
    NIdentifier(const std::string& name) : name(name) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NMethodCall : public NExpression {
public:
    const NIdentifier& id;
    ExpressionList arguments;
    NMethodCall(const NIdentifier& id, ExpressionList& arguments) :
        id(id), arguments(arguments) { }
    NMethodCall(const NIdentifier& id) : id(id) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NBinaryOperator : public NExpression {
public:
    int op;
    NExpression& lhs;
    NExpression& rhs;
    NBinaryOperator(NExpression& lhs, int op, NExpression& rhs) :
        lhs(lhs), rhs(rhs), op(op) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NUnaryOperator : public NExpression {
public:
    int op;
    NExpression& rhs;
    NBinaryOperator(int op, NExpression& rhs) :
        rhs(rhs), op(op) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};


class NAssignment : public NExpression {
public:
    NIdentifier& lhs;
    NExpression& rhs;
    NAssignment(NIdentifier& lhs, NExpression& rhs) : 
        lhs(lhs), rhs(rhs) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NBlock : public NExpression {
public:
    StatementList statements;
    NBlock() { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NExpressionStatement : public NStatement {
public:
    NExpression& expression;
    NExpressionStatement(NExpression& expression) : 
        expression(expression) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NVariableDeclaration : public NStatement {
public:
    const std::string& type;
    NIdentifier& id;
    NExpression *assignmentExpr;
    NVariableDeclaration(const std::string& type, NIdentifier& id) :
        type(type), id(id) { }
    NVariableDeclaration(const std::string& type, NIdentifier& id, NExpression *assignmentExpr) :
        type(type), id(id), assignmentExpr(assignmentExpr) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NFunctionDeclaration : public NStatement {
public:
    const std::string& type;
    const NIdentifier& id;
    VariableList arguments;
    NBlock& block;
    NFunctionDeclaration(const std::string& type, const NIdentifier& id, 
            const VariableList& arguments, NBlock& block) :
        type(type), id(id), arguments(arguments), block(block) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NProcDeclaration : public NStatement {
public:
    const NProcHeader& header;
    NBlock& block;
    NProcDeclaration(const NProcHeader& header, NBlock& block) :
        header(header), block(block) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NProcHeader : public NStatement {
public:
    const NIdentifier& id;
    VariableList arguments;
    NProcHeader(const NIdentifier& id, const VariableList& arguments) :
        id(id), arguments(arguments) { }
    NProcHeader(const NIdentifier& id) :
        id(id) { }
    //virtual llvm::Value* codeGen(CodeGenContext& context);
};
