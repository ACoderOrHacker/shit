/++
 + A simple logger for shit
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.logger;
@safe:
export:

import std.stdio;
import std.traits;
import helper.formatter;

/++ 
 + Log it to console
 + Params:
 +   fmt = The format string
 +   args = Items to write
 +/
void log(Char, A...)(in Char[] fmt, A args)
{
    write("shit: ");
    Formatter.
    writefln(fmt, args);
}

/++
 + Log it to console
 + Params:
 +   args = Items to write
 +/
void log(alias fmt, A...)(A args)
    if (isSomeString!(typeof(fmt)))
{
    log(fmt, args);
}

/++
 + Log a internal error to console
 + Params:
 +   msg = The message to show
 +/
void internalError(Char)(in Char[] msg)
{
    log(
        "internal error: " ~ msg ~
            "\n  please report on https://github.com/ACoderOrHacker/shit/issues");
}
