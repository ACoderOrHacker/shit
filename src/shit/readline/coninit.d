module shit.readline.coninit;

import core.sys.windows.windows;

void consoleInit()
{
    version (Windows)
    {
        static void setHandleANSIEscape(HANDLE hConsole)
        {
            DWORD mode;
            if (!GetConsoleMode(hConsole, &mode))
                return; // unknown-handle

            if ((mode & ENABLE_VIRTUAL_TERMINAL_PROCESSING) == 0)
            {
                SetConsoleMode(hConsole, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
            }
        }

        setHandleANSIEscape(GetStdHandle(STD_ERROR_HANDLE));
        setHandleANSIEscape(GetStdHandle(STD_OUTPUT_HANDLE));
    }
}
