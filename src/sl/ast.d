/++
 + The shit-language AST defiations
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module sl.ast;

import prettyprint;

alias Identifier = string; // identifer string type

private template initASTNode()
{
    static this()
    {
        TypeRegistry.register!(typeof(this))();
    }
}

class ASTNode
{
    void codegen()
    {
    }
}

class StmtASTNode : ASTNode
{
    mixin initASTNode;
}

class ExprASTNode : ASTNode
{
    mixin initASTNode;
}

class ProgramASTNode : BlockASTNode
{
    mixin initASTNode;
}

class BlockASTNode : StmtASTNode
{
    mixin initASTNode;
    StmtASTNode[] stmts;
}

class ReturnASTNode : StmtASTNode
{
    mixin initASTNode;
    ExprASTNode returnValue;
}

class FunctionDeclASTNode : StmtASTNode
{
    mixin initASTNode;
    Identifier id;
    BlockASTNode block;
    Identifier params;

    /// true if the function is a variadic function
    bool isVariadicFunction;
}

class ForInStmtASTNode : StmtASTNode
{
    mixin initASTNode;
    Identifier[] loopVariables;
    ExprASTNode container;
}

class SwitchStmtASTNode : StmtASTNode
{
    mixin initASTNode;
    ExprASTNode controlExpr;

    CaseASTNode[] cases;
    BlockASTNode defaultCase;
}

class CaseASTNode : ASTNode
{
    mixin initASTNode;
    ExprASTNode constantExpr;
    BlockASTNode block;
}

struct ConditionClause
{
    ExprASTNode condition;
    BlockASTNode block;
}

class IfStmtASTNode : StmtASTNode
{
    mixin initASTNode;

    ConditionClause[] clauses;
    BlockASTNode elseClause;
}

class WhileStmtASTNode : StmtASTNode
{
    mixin initASTNode;
    ExprASTNode condition;
    BlockASTNode block;
}

class DoWhileStmtASTNode : StmtASTNode
{
    mixin initASTNode;
    ExprASTNode condition;
    BlockASTNode block;
}

class VarDeclASTNode : StmtASTNode
{
    mixin initASTNode;
    Identifier[] vars;
    ExprASTNode[] exprs;
}

struct KeyAndValue
{
    ExprASTNode key;
    ExprASTNode value;
}

class TableConstructorASTNode : ExprASTNode
{
    mixin initASTNode;

    KeyAndValue[] keyAndValues;
}

class FunctionCallASTNode : ExprASTNode
{
    mixin initASTNode;
    ExprASTNode[] args;
    Identifier returnType;
}

class IntegerLiteralASTNode : ExprASTNode
{
    mixin initASTNode;
    long integerData;
}

class FloatLiteralASTNode : ExprASTNode
{
    mixin initASTNode;
    double floatNumber; // TODO: Use decimal type
}

class StringLiteralASTNode : ExprASTNode
{
    mixin initASTNode;
    string stringData;
}

class BooleanLiteralASTNode : ExprASTNode
{
    mixin initASTNode;
    bool booleanValue;
}

class NilASTNode : ExprASTNode
{
    mixin initASTNode;
}

class BinaryExprASTNode : ExprASTNode
{
    mixin initASTNode;
    enum OpType
    {
        Add,
        Sub,
        Mul,
        Div,
        Mod,
        Pow,
        BitOr,
        BitAnd,
        LeftShift,
        RightShift,
        NotEqual,
        Equal,
        Greater,
        Less,
        GreaterOrEqual,
        LessOrEqual,
        And,
        Or
    }

    OpType op;
    ExprASTNode left;
    ExprASTNode right;
}

class UnaryExprASTNode : ExprASTNode
{
    mixin initASTNode;
    enum OpType
    {
        Not,
        Negative,
        XOr
    }

    OpType op;
    ExprASTNode unary;
}

class PipelineExprASTNode : ExprASTNode
{
    mixin initASTNode;
    string cmd; // TODO: One more thing...
}

class BreakASTNode : StmtASTNode
{
    mixin initASTNode;
}

class ContinueASTNode : StmtASTNode
{
    mixin initASTNode;
}
