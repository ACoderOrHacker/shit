module shit.helper.logger;

import std.stdio;

void log(string msg)
{
    writeln("shit: " ~ msg);
}

void internalError(string msg)
{
    log(
        "internal error: " ~ msg ~
            "\n  please report on https://github.com/ACoderOrHacker/shit/issues");
}
