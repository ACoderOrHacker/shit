module helper.signal;

import core.stdc.signal;
import core.stdc.stdio;
import core.stdc.stdlib : exit;

extern (C) @nogc
nothrow void segfaultHandle(int)
{
    printf("shit: segmentation fault" ~
            "\n  please report on https://github.com/ACoderOrHacker/shit/issues");
    exit(1);
}

void initSignals()
{
    signal(SIGSEGV, &segfaultHandle);
}
