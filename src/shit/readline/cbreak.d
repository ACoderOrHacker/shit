module shit.readline.cbreak;

version (Posix)
{
    import core.sys.posix.termios;
    import core.sys.posix.unistd;
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
private:
    version (Posix)
    {
        alias Config = termios;
    }
    version (Windows)
    {
        alias Config = DWORD;
    }
    Config original;
    bool isCbreak;

    void saveCurrent()
    {
        version (Posix)
        {
            if (tcgetattr(STDIN_FILENO, &original) != 0)
            {
                throw new CbreakException("Failed to get terminal attributes");
            }
        }
        else version (Windows)
        {
            if (GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &original) == 0)
            {
                throw new CbreakException("Failed to get console mode");
            }
        }
    }

    void applySettings(Config settings)
    {
        version (Posix)
        {
            if (tcsetattr(STDIN_FILENO, TCSANOW, &settings) != 0)
            {
                throw new CbreakException("Failed to set terminal attributes");
            }
        }
        else version (Windows)
        {
            if (SetConsoleMode(hStdin, settings) == 0)
            {
                throw new CbreakException("Failed to set console mode");
            }
        }
    }

public:
    this()
    {
        saveCurrent();
    }

    ~this()
    {
        applySettings(original);
    }

    final void cbreak()
    {
        if (isCbreak)
            return;
        Config settings;
        version (Posix)
        {
            settings = original;
            settings.c_lflag &= ~(ICANON | ECHO);

            settings.c_cc[VMIN] = 1;
            settings.c_cc[VTIME] = 0;
        }
        version (Windows)
        {
            settings = original & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT);
        }
        applySettings(settings);
        isCbreak = true;
    }

    final void restore()
    {
        if (!isCbreak)
            return;
        applySettings(original);
        isCbreak = false;
    }
}
