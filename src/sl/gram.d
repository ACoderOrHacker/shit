/++
 + The shit-language PEG grammar defiations
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module sl.gram;

import pegged.grammar;

mixin(grammar(`
ShitGrammar:
    Program                   <- Block
    Spacing                   <- (space / Comment)*
    Comment                   <- BlockComment / LineComment

    BlockComment              <~ :'- *' (!'* -' .)* :'* -'
    LineComment               <~ :'#' (!endOfLine .)* :endOfLine

    EscapeSequence            <- backslash (
        quote /
        doublequote /
        backslash /
        [abfnrtv] /
        'x' HexDigit HexDigit /
        'u' HexDigit HexDigit HexDigit HexDigit /
        'U' HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit
    )
    Sign                      <- ('+' / '-')?
    Identifier                <- !Keyword [a-zA-Z_] [a-zA-Z0-9_]*

    Keyword                   <~ "nil" / 
        "true" / "false" / "and" / "or" / 
        "not" / "break" / "continue" / "do" / 
        "end" / "while" / "if" / "then" / 
        "elseif" / "else" / "switch" / 
        "case" / "default" / "for" / 
        "in" / "function" / "return"
    Integer                   <- digit+
    HexDigit                  <- [0-9a-fA-F]
    HexInteger                <- ("0x" / "0X") HexDigit (HexDigit / "_")*
    IntegerLiteral            <- Integer / HexInteger

    FloatLiteral              <- Sign? Integer '.' Integer? (("e" / "E") Sign? Integer)?

    DoubleQuotedString        <- doublequote (DQChar)* doublequote
    DQChar                    <- EscapeSequence / (!doublequote .)
    WysiwygString             <- 'r' doublequote DQChar* doublequote
    AlternateWysiwygString    <- backquote (!backquote .)* backquote
    StringLiteral             <- WysiwygString / AlternateWysiwygString / DoubleQuotedString
    CharLiteral               <- 'c' doublequote (!doublequote (EscapeSequence / .)) doublequote

    Nil                       <- "nil"
    BooleanLiteral            <- "true" / "false"
    Literal                   <- Nil / 
        BooleanLiteral / IntegerLiteral / 
        FloatLiteral / StringLiteral / CharLiteral

    expr                      < ParenExpr / 
        Literal / TableConstructor / 
        BinaryExpr / UnaryExpr / Pipeline

    ParenExpr                 < '(' expr ')'
    Var                       < Identifier / IndexExpr

    IndexExpr                 < (expr '[' expr ']') / (Identifier '.' Identifier)
    FunctionCall              < expr Args
    Args                      < ('(' exprList? ')') / TableConstructor / StringLiteral

    TableConstructor          < '{' FieldList? '}'
    FieldList                 < Field (FieldSep Field)* FieldSep?
    Field                     < (expr ':' expr) / (Identifier '=' expr) / expr
    FieldSep                  <~ ','

    exprList                  < expr (',' expr)*
    VarList                   < Var (',' Var)*

    BinaryOp                  <~ '+' / 
        '-' / '*' / '/' / '%' / 
        '^' / '|' / '&' / '>>' / '<<' / '<' / 
        '<=' / '>' / '>=' / '==' / '~=' / "and" / "or"
    UnaryOp                   <~ '-' / 'not' / '~'
    BinaryExpr                < expr BinaryOp expr
    UnaryExpr                 < expr UnaryOp expr

    Block                     < stmt*
    stmt                      < ';' / 
        VarDecl / FunctionCall / Break / Continue / 
        DoBlock / WhileStmt / DoWhileStmt / IfStmt / 
        SwitchStmt / ForInStmt / FunctionDecl / RetStmt / Pipeline

    VarDecl                   < VarList '=' exprList
    Break                     < "break"
    Continue                  < "continue"
    DoBlock                   < "do" Block "end"
    WhileStmt                 < "while" expr "do" Block "end"
    DoWhileStmt               < "do" Block "while" expr "end"
    IfStmt                    < "if" expr "then" Block (ElseIfStmt)* (ElseStmt)? "end"
    ElseIfStmt                < "elseif" expr "then" Block
    ElseStmt                  < "else" Block
    SwitchStmt                < "switch" expr CaseStmt+ (DefaultStmt)? "end"
    CaseStmt                  < "case" (expr / Range) Block
    DefaultStmt               < "default" Block
    ForInStmt                 < "for" NameList "in" (expr / Range) "do" Block "end"

    FunctionDecl              < "function" Identifier FuncBody
    FuncBody                  < '(' ParList? ')' Block "end"
    ParList                   < (NameList (',' '...')?) / '...'
    NameList                  < Identifier (',' Identifier)*
    RetStmt                   < "return" exprList?

    # Command definations
    Pipeline                  < Command (("|" Command) / ("&&" Command) / ("||" Command) / ("&" Command?))*
    Command                   < (SimpleCommand / SubshellCommand) (Redirection)*
    SimpleCommand             < (Word / QuotedWord / CommandVariable)+
    SubshellCommand           < "(" Pipeline ")"
    Word                      < [^\\s|&;<>()$'"]+
    QuotedWord                < SingleQuoted / DoubleQuoted
    SingleQuoted              < quote [^']* quote
    DoubleQuoted              < doublequote (CommandVariable / DQChar)* doublequote
    CommandVariable           < SimpleVariable / BracedVariable / CommandOutput / CommandStatus / CommandFailure
    SimpleVariable            < "\\$" Identifier
    BracedVariable            < "\\$" "{" expr "}"
    CommandOutput             < "\\$output(" Pipeline ")" / "\\$(" Pipeline ")" / backquote Pipeline backquote
    CommandStatus             < "\\$status(" Pipeline ")" / "\\$?(" Pipeline ")"
    CommandFailure            < "\\$failure(" Pipeline ")" / "\\$!(" Pipeline ")"
    Redirection               < (FileDescriptor? RedirectionOp FileTarget) / (FileDescriptor ">&" FileDescriptor) / (FileDescriptor "<&" FileDescriptor)
    FileDescriptor            <~ digit+
    RedirectionOp             <~ "<" / ">" / ">>" / ">&" / "<&" / ">|" / "2>"
    FileTarget                < Word / QuotedWord

    Range                     < (IntegerLiteral / CharLiteral) ".." (IntegerLiteral / CharLiteral)
`));