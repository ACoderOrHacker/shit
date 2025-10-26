/++
 + The shit-language AST defiations
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module sl.ast;

import prettyprint;
public import std.bigint;

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
    void codegen() {}
}

class StmtASTNode : ASTNode
{
    //mixin initASTNode;
    static this()
    {
        TypeRegistry.register!(StmtASTNode)();
    }
}

class ExprASTNode : ASTNode
{
}

class ProgramASTNode : BlockASTNode
{
}

class BlockASTNode : StmtASTNode
{
    StmtASTNode[] stmts;
}

class ReturnASTNode : StmtASTNode
{
    ExprASTNode returnValue;
}

class FunctionDeclASTNode : StmtASTNode
{
    Identifier id;
    BlockASTNode block;
    Identifier params;

    /// true if the function is a variadic function
    bool isVariadicFunction;
}

class ForInStmtASTNode : StmtASTNode
{
    Identifier[] loopVariables;
    ExprASTNode container;
}

class SwitchStmtASTNode : StmtASTNode
{
    ExprASTNode controlExpr;

    CaseASTNode[] cases;
    BlockASTNode defaultCase;
}

class CaseASTNode : ASTNode
{
    ExprASTNode constantExpr;
    BlockASTNode block;
}

class IfStmtASTNode : StmtASTNode
{
    struct ConditionClause
    {
        ExprASTNode condition;
        BlockASTNode block;
    }

    ConditionClause[] clauses;
    BlockASTNode elseClause;
}

class WhileStmtASTNode : StmtASTNode
{
    ExprASTNode condition;
    BlockASTNode block;
}

class DoWhileStmtASTNode : StmtASTNode
{
    ExprASTNode condition;
    BlockASTNode block;
}

class VarDeclASTNode : StmtASTNode
{
    Identifier[] vars;
    ExprASTNode[] exprs;
}

class TableConstructorASTNode : ExprASTNode
{
    struct KeyAndValue
    {
        ExprASTNode key;
        ExprASTNode value;
    }

    KeyAndValue[] keyAndValues;
}

class FunctionCallASTNode : ExprASTNode
{
    ExprASTNode[] args;
    Identifier returnType;
}

class IntegerLiteralASTNode : ExprASTNode
{
    BigInt integerData;
}

class FloatLiteralASTNode : ExprASTNode
{
    double floatNumber; // TODO: Use decimal type
}

class StringLiteralASTNode : ExprASTNode
{
    string stringData;
}

class BooleanLiteralASTNode : ExprASTNode
{
    bool booleanValue;
}

class NilASTNode : ExprASTNode
{
}

class BinaryExprASTNode : ExprASTNode
{
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
    string cmd; // TODO: One more thing...
}

class BreakASTNode : StmtASTNode
{
}

class ContinueASTNode : StmtASTNode
{
}