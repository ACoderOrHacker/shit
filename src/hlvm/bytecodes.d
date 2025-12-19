module hlvm.bytecodes;

import std.bitmanip;
import core.stdc.stdint;

/++ 
 + Opcodes
 + Instructions have an opcode for first 8 bits (256 kinds)
 + Instructions can have this following formats:
 + 
 + iAB:   |        A(16)        |        B(8)        |        Opcode(8)        |
 + iABC:  |    A(8)    |    B(8)    |      C(8)      |        Opcode(8)        |
 + iAx:   |                    Ax(24)                |        Opcode(8)        |
 + isAx:  |                sAx(24)(signed)           |        Opcode(8)        |
 + iAsJ:  |        A(8)         |       sJ(16)       |        Opcode(8)        |
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
    JNT, //            iAsJ;  if not R(A) then pc += sJ
    JNF, //            iAsJ;  if R(A) then pc += sJ
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

struct ArgumentAB
{
    uint16_t A;
    uint8_t B;
}

struct ArgumentABC
{
    uint8_t A;
    uint8_t B;
    uint8_t C;
}

struct ArgumentAsJ
{
    uint8_t A;
    int16_t sJ;
}

struct Bytecode
{
    private
    {
        struct BytecodeData
        {
            Opcode opcode;
            union
            {
                ArgumentAB argAB_;
                ArgumentABC argABC_;
                ArgumentAsJ argAsJ_;
            }
        }

        union
        {
            BytecodeData data;
            mixin(bitfields!(
                    Opcode, "opcodeBits", 8,
                    uint32_t, "oprandBits", 24
            ));
        }
    }

    @property
    Opcode opcode()
    {
        return opcodeBits;
    }

    @property
    ArgumentAB argAB()
    {
        return data.argAB_;
    }

    @property
    ArgumentABC argABC()
    {
        return data.argABC_;
    }

    @property
    uint32_t argAx()
    {
        return oprandBits;
    }

    @property
    int32_t argSAx()
    {
        return cast(int32_t) oprandBits;
    }

    @property
    ArgumentAsJ argAsJ()
    {
        return data.argAsJ_;
    }
}
