module hlvm.frame;

import hlvm.state;
import hlvm.frame;
import hlvm.callinfo;

struct Frame
{
    Callinfo callInfo;
    size_t pc;
}

/++ 
 + Exit current frame from state
 + Make sure there is a frame on callstack
 + Params:
 +   state = Running vm
 +/
void exitFrame(HLVMState state)
{
    Frame frame = state.callstack.pop();
    state.callInfo = frame.callInfo;
    state.pc = frame.pc;
}
