/++
 + Console title helper for shit
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.title;
@safe:
export:

/++ 
 + Set console title to the given string
 + Params:
 +   title = The title string
 +/
void setConsoleTitle(string title) @trusted
{
    version (Windows)
    {
        import std.utf : toUTF16z;
        import core.sys.windows.windows : SetConsoleTitleW;

        auto wtitle = toUTF16z(title);
        SetConsoleTitleW(wtitle);
    }
    else version (Posix)
    {
        import std.stdio;

        stdout.writef!"\x1b]0;%s\x07"(title);
        stdout.flush();
    }
}
