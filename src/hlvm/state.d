module hlvm.state;

import core.stdc.stdint;
import hlvm.base.stack;
public import hlvm.bytecodes;
public import hlvm.thunk;
public import hlvm.vmobject;
public import hlvm.register;
public import hlvm.frame;
public import hlvm.callinfo;

struct HLVMException
{
    bool onException = false;
    HLVMObject exception;
    string msg;
}

class HLVMState
{
    Thunk thunk;

    Callinfo callInfo;
    size_t pc;
    Stack!HLVMObject stack;
    Stack!Frame callstack;
    RegistersManager registers;

    // for event
    alias EventHooksPerObject = Stack!HLVMObject;
    EventHooksPerObject[HLVMObject] eventHooks;

    // for exception
    HLVMException exception;

    // for `exit`
    bool isStopped = false; // control stopper for exit
    int exitCode = 0;

    // for extending-bits
    uint32_t extendingBits;

    this(Thunk runThunk)
    {
        thunk = runThunk;
        registers = new RegistersManager;
    }

    HLVMObject opIndex(KstIndex kstIndex)
    {
        return thunk.consts[kstIndex];
    }

    HLVMObject opIndex(Register reg)
    {
        return registers.getObjectFromRegister(reg);
    }

    void opIndexAssign(HLVMObject object, Register reg)
    {
        registers.setRegister(reg, object);
    }

    void throwException(HLVMObject exception, string msg = "")
    {
        this.exception.exception = exception;
        this.exception.msg = msg;
        this.exception.onException = true;
    }

    void resetException()
    {
        this.exception.exception = HLVMObject.init;
        this.exception.msg = string.init;
        this.exception.onException = false;
    }

    void catchException()
    {
        if (!this.exception.onException)
            return; // no exception

        if (this.exception !in this.eventHooks)
            exceptionStandardHandler(); // no user-defined event handler, use standard handler
        
        callFunction(this.eventHooks[this.exception].top, this.exception.exception, this.exception.msg.to!HLVMObject); // TODO: actually, no converter there
    }

    private void exceptionStandardHandler()
    {
        // TODO: no impl
    }
}
