module shit.helper.title;

void setConsoleTitle(string title)
{
    version (Windows)
    {
        import std.utf : toUTF16z;
        import core.sys.windows.windows : SetConsoleTitleW;

        auto wtitle = toUTF16z(title);
        SetConsoleTitleW(wtitle);
    }
    else version (linux)
        version (OSX)
        {
            import core.stdc.stdio;

            printf("\033]0;%s\007", title.ptr);
            fflush(stdout);
        }
}
