module hlvm.objects.base;

public import hlvm.vmobject;

/++ 
 + Create a HLVM object
 + Params:
 +   type = HLVM Value type
 +   value = HLVM Object value
 + Returns: The created object
 +/
HLVMObject newObject(TValue.Type type, Value value = Value.init)
{
    HLVMObject obj = new HLVMObject;
    obj.value.type = type;
    obj.value.value = value;

    return obj;
}
