module hlvm.vm;

import std.exception;
import hlvm.state;
import hlvm.objects;

class UnknownError : Error
{
    this(string msg, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, nextInChain);
    }
}

int run(HLVMState state)
{
    state.callInfo = state.thunk.callInfo;
    state.pc = 0;
    try
    {
        for (;;)
        {
            if (state.isStopped)
                break;

            Bytecode code = state.callInfo.codes[state.pc];
            execute(state, code);

            if (state.exception.onException)
                state.catchException(state);

            if (state.callInfo.codes.length == (state.pc + 1))
            {
                // at the end of Callinfo
                // just exit the frame

                if (state.callstack.empty)
                    break;
                exitFrame(state);
            }

            state.pc++;
        }
    }
    catch (Exception e)
    {
        // a non-known issue maybe
        // just throw an error
        throw new UnknownError("Fatal: " ~ e.msg);
    }

    return state.exitCode;
}

void execute(HLVMState state, Bytecode code)
{
    final switch (code.bytecodeData.opcode)
    {
    case Opcode.MOV:
        state[Register(code.bytecodeAB.operandA)] = state[Register(code.bytecodeAB.operandB)];
        break;
    case Opcode.LOADK:
        state[Register(code.bytecodeAB.operandA)] = state[KstIndex(code.bytecodeAB.operandB)];
        break;
    case Opcode.LOADNIL:
        state[Register(code.bytecodeAx.operandAx)] = nilObject;
        break;
    case Opcode.PUSH:
        state.stack.push(state[Register(code.bytecodeAx.operandAx)]);
        break;
    case Opcode.POP:
        state[Register(code.bytecodeAx.operandAx)] = state.stack.pop();
    }
}
