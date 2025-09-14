/++
 + Defines signals and initializer for shit
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/

module helper.signal;
@safe:
export:

import core.stdc.stdio;
import core.stdc.signal;
import core.stdc.stdlib;

private enum segfaultMessage = r"
shit: segmentation fault
  please report on https://github.com/ACoderOrHacker/shit/issues
";

extern (C) @nogc
private nothrow void segfaultHandle(int) @trusted
{
    printf(segfaultMessage);
    exit(1);
}

/++ 
 + Initialize signals
 +/
void initSignals() @trusted
{
    signal(SIGSEGV, &segfaultHandle);
}

static this()
{
    initSignals();
}