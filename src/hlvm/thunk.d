module hlvm.thunk;

import hlvm.callinfo;
import hlvm.vmobject;

struct KstIndex
{
    size_t index;
}

alias KstPool = Objects;

class Thunk
{
    Callinfo callInfo;
    KstPool consts;
}
