/++
 + HLVM registers manager
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module hlvm.register;

import std.bitmanip;
import core.stdc.stdint;
import hlvm.base.stack;
import hlvm.base.array;
import hlvm.vmobject;

/++ 
 + Register structure
 + `data` is the original data
 + `isGlobal` is true when the register ID is for global
 + `registerID` is for indexing in the `Registers`
 + See_Also: RegistersManager
 +/
struct Register
{
    union
    {
        int32_t data;
        mixin(bitfields!(
                bool, "isGlobal", 1,
                uint32_t, "registerID", 31
        ));
    }
}

alias Registers = Objects;

/++ 
 + Managing registers
 +/
class RegistersManager
{
    Registers global;
    Stack!Registers locals;

    /++ 
     + Returns: current local registers
     +/
    auto currentLocalRegisters()
    {
        return locals.front;
    }

    /++ 
     + Add a local registers area for locals
     +/
    void addLocalRegisters()
    {
        locals.push();
    }

    /++ 
     + Delete a local registers area for locals
     + Throws: `StackNoElementsException` if no local registers
     +/
    void deleteLocalRegisters()
    {
        locals.pop();
    }

    /++ 
     + Set a object into a given register
     + Params:
     +   reg = The register in current manager
     +   object = The given object
     + Throws: `StackNoElementsException` if no local registers area
     +/
    void setRegister(Register reg, HLVMObject object)
    {
        if (reg.isGlobal)
            global[reg.registerID] = object;
        else
            locals.top[reg.registerID] = object;
    }

    /++ 
     + Get a object from a given register
     + Params:
     +   reg = The register in current manager
     + Throws: `StackNoElementsException` if no local registers area or no object
     +/
    HLVMObject getObjectFromRegister(Register reg)
    {
        if (reg.isGlobal)
        {
            return global[reg.registerID];
        }
        else
        {
            return locals.top[reg.registerID];
        }
    }
}
