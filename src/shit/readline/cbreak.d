module shit.readline.cbreak;

version (Posix)
{
    import core.sys.posix.termios;
}
else version (Windows)
{
    import core.sys.windows.windows;
}
else
{
    static assert(false, "Unsupported platform");
}

export class CbreakException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class Cbreak
{
    this()
    {
        cbreak();
    }

    ~this()
    {
        restore();
    }

    final void cbreak()
    {
        version (Posix)
        {
            if (tcgetattr(0, &originalTermios) != 0)
            {
                throw new CbreakException("Failed to get terminal attributes");
            }

            termios newTermios = originalTermios;
            newTermios.c_lflag &= ~(ICANON | ECHO);
            newTermios.c_cc[VMIN] = 1;
            newTermios.c_cc[VTIME] = 0;

            if (tcsetattr(0, TCSANOW, &newTermios) != 0)
            {
                throw new CbreakException("Failed to set terminal attributes");
            }
        }
        version (Windows)
        {
            hStdin = GetStdHandle(STD_INPUT_HANDLE);
            if (hStdin == INVALID_HANDLE_VALUE)
            {
                throw new CbreakException("Failed to get stdin handle");
            }

            if (GetConsoleMode(hStdin, &originalMode) == 0)
            {
                throw new CbreakException("Failed to get console mode");
            }

            DWORD newMode = originalMode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT);
            if (SetConsoleMode(hStdin, newMode) == 0)
            {
                throw new CbreakException("Failed to set console mode");
            }
        }
    }

    final void restore()
    {
        version (Posix)
        {
            tcsetattr(0, TCSANOW, &originalTermios);
        }

        version (Windows)
        {
            if (hStdin != INVALID_HANDLE_VALUE)
            {
                SetConsoleMode(hStdin, originalMode);
            }
        }
    }

private:
    version (Posix)
    {
        termios originalTermios;
    }
    version (Windows)
    {
        HANDLE hStdin;
        DWORD originalMode;
    }
}
