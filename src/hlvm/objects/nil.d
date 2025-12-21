module hlvm.objects.nil;

import hlvm.objects.base;

immutable(HLVMObject) nilObject;

static this()
{
    nilObject = newObject(TValue.Type.NIL);
}