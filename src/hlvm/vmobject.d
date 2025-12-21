module hlvm.vmobject;

import hlvm.base.array;
import hlvm.callinfo;

union Value
{
    void* ud; //                     userdata
    real number; //                  number
    string str; //                   string
    Function func; //                function
    HLVMObject[HLVMObject] table; // table
}

struct TValue
{
    /++ 
     + Object type
     +/
    enum Type
    {
        NIL,
        NUMBER,
        STRING,
        FUNCTION,
        USERDATA,
        TABLE
    }

    Type type;
    Value value;
}

class HLVMObject
{
    TValue value;
}

alias Objects = HLVMArray!HLVMObject;
