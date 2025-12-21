module hlvm.callinfo;

import hlvm.state;
import hlvm.bytecodes;

alias DNativeFunction = void function(const(HLVMState*)) nothrow;

struct Function
{
    enum Type
    {
        D_FUNCTION,
        HLVM_FUNCTION
    }

    Type type;
    union
    {
        Bytecodes codes;
        DNativeFunction nativeFunction;
    }

    this(Bytecodes codes)
    {
        this.type = Type.HLVM_FUNCTION;
        this.codes = codes;
    }

    this(Type tp, DNativeFunction nativeFunc)
    {
        this.type = Type.D_FUNCTION;
        this.nativeFunction = nativeFunc;
    }
}

class Callinfo
{
    Bytecodes codes;
}
