/++
 + HLVM Bytecodes
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module hlvm.bytecodes;

import std.bitmanip;
import core.stdc.stdint;
import hlvm.base.array;

/++ 
 + Opcodes
 + Instructions have an opcode for first 8 bits (256 kinds)
 + Instructions can have this following formats:
 + 
 + iAB:   |        A(16)        |        B(8)        |        Opcode(8)        |
 + iABC:  |    A(8)    |    B(8)    |      C(8)      |        Opcode(8)        |
 + iAx:   |                    Ax(24)                |        Opcode(8)        |
 + isAx:  |                sAx(24)(signed)           |        Opcode(8)        |
 + iAsB:  |        A(8)         |       sB(16)       |        Opcode(8)        |
 +
 + In following comments, these means:
 + S(top): the top of stack
 + SP(<index>): get and pop S(top)
 + R(<reg>): register <reg>
 + Kst(<index>): A constant <index> from constant pool
 + Ext(<index>): Extend-bits in <index>
 +/
enum Opcode : uint8_t
{
    // Memory & Stack accessing
    MOV, //           iAB;   R(A) = R(B)
    LOADK, //         iAB;   R(A) = Kst(B)
    LOADNIL, //       iAx;   R(Ax) = nil
    PUSH, //          iAx;   S(top) = R(Ax)
    POP, //           iAx;   R(Ax) = SP(0)

    // Calculation
    // Note: 
    // These bytecodes are stored in iAB format.
    // Usually, the result produced by these bytecodes is a temporary value
    // Putting it into a register would waste the register
    // And also increase the number of Extra arguments bytecode
    // So just put it to the top of stack
    ADD, //            iAB;   S(top) = R(A) + R(B)
    SUB, //            iAB;   S(top) = R(A) - R(B)
    MUL, //            iAB;   S(top) = R(A) * R(B)
    DIV, //            iAB;   S(top) = R(A) / R(B)
    IDIV, //           iAB;   S(top) = R(A) // R(B)
    MOD, //            iAB;   S(top) = R(A) % R(B)
    POW, //            iAB;   S(top) = R(A) ^ R(B)
    SHL, //            iAB;   S(top) = R(A) << R(B)
    SHR, //            iAB;   S(top) = R(A) >> R(B)
    BAND, //           iAB;   S(top) = R(A) & R(B)
    BOR, //            iAB;   S(top) = R(A) | R(B)
    BXOR, //           iAB;   S(top) = R(A) ~ R(B)
    BNOT, //           iAx;   S(top) = ~R(Ax)

    // Logical Calculation
    NOT, //            iAx;   S(top) = not R(Ax)
    EQ, //             iAB;   S(top) = R(A) == R(B)
    LT, //             iAB;   S(top) = R(A) < R(B)
    LE, //             iAB;   S(top) = R(A) <= R(B)
    GT, //             iAB;   S(top) = R(A) > R(B)
    GE, //             iAB;   S(top) = R(A) >= R(B)

    // Jumping & Function
    JMP, //            isAx;  pc += sJ
    JNT, //            iAsB;  if not R(A) then pc += sJ
    JNF, //            iAsB;  if R(A) then pc += sJ
    CALL, //           iAB;   R(A)(SP(0), ..., SP(B))
    RET1, //           isAx;  if sAx < 0 then return else return R((Ax)sAx)
    RET, //            iAB;   return R(A), ..., R(A + B - 2)

    // Table
    FIELD, //          iABC;  R(A) = R(B)[R(C)]
    FIELDREF, //       iABC;  R(A) ref= R(B)[R(C)]

    // Extending oprands
    EXT_1, //          iAx;  Ext(0) = R(Ax)
    EXT_2, //          iAx;  Ext(1) = R(Ax)
}

struct BytecodeData
{
    mixin(bitfields!(
            Opcode, "opcode", 8,
            uint32_t, "operand", 24
    ));
}

struct BytecodeAx
{
    mixin(bitfields!(
            Opcode, "opcodeAx", 8,
            uint32_t, "operandAx", 24
    ));
}

struct BytecodeAB
{
    mixin(bitfields!(
            Opcode, "opcodeAB", 8,
            uint16_t, "operandA", 16,
            uint8_t, "operandB", 8
    ));
}

struct BytecodeABC
{
    mixin(bitfields!(
            Opcode, "opcodeABC", 8,
            uint8_t, "operandA", 8,
            uint8_t, "operandB", 8,
            uint8_t, "operandC", 8
    ));
}

struct BytecodeSAx
{
    mixin(bitfields!(
            Opcode, "opcodeSAx", 8,
            uint32_t, "operandSAx", 24
    ));
}

struct BytecodeAsB
{
    mixin(bitfields!(
            Opcode, "opcodeAsB", 8,
            uint8_t, "operandA", 8,
            uint16_t, "operandSB", 16
    ));
}

struct Bytecode
{
    union
    {
        uint32_t originValue_;
        BytecodeData bytecodeData;
        BytecodeAB bytecodeAB;
        BytecodeABC bytecodeABC;
        BytecodeAsB bytecodeAsB;
        BytecodeAx bytecodeAx;
        BytecodeSAx bytecodeSAx;
    }

    @property
    Opcode opcode()
    {
        return bytecodeData.opcode;
    }
}

alias Bytecodes = HLVMArray!Bytecode;
