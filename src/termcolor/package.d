module termcolor;

import std.stdint : uint8_t;
import std.stdio : File;
import std.conv : to;
import std.ascii : toUpper;

version (Posix)
{
    static import core.sys.posix.unistd;

    alias FileDescriptor = int;
}
else version (Windows)
{
    import core.sys.windows.windows;

    alias FileDescriptor = HANDLE;
}
else
{
    static assert(false, "Unsupported platform");
}

/// Checks if the file descriptor referring to a tty
private bool isatty(File stream)
{
    version (Posix)
    {
        return isatty(stream.fileno()) == 1;
    }
    else version (Windows)
    {
        HANDLE hStream = stream.windowsHandle();
        if (hStream == INVALID_HANDLE_VALUE)
            return false;

        DWORD mode;
        return GetConsoleMode(hStream, &mode) != 0;
    }
}

// Color definations

struct RGBColor
{
    uint8_t r;

    uint8_t g;
    uint8_t b;
}

struct Legacy16Color
{
    uint8_t color;
}

struct OnRGBColor
{
    this(uint8_t r, uint8_t g, uint8_t b)
    {
        color = RGBColor(r, g, b);
    }

    RGBColor color;

    @property
    uint8_t r() const
    {
        return color.r;
    }

    @property
    uint8_t g() const
    {
        return color.g;
    }

    @property
    uint8_t b() const
    {
        return color.b;
    }
}

struct RGBColorType(uint8_t r, uint8_t g, uint8_t b)
{
    RGBColor color;
    alias color this;

    this()
    {
        color = RGBColor(r, g, b);
    }

    RGBColor opCast(T)() const if (T == RGBColor)
    {
        return color;
    }
}

struct Legacy16ColorType(uint8_t color)
{
    Legacy16Color color;
    alias color this;

    this()
    {
        this.color = Legacy16Color(color);
    }

    Legacy16Color opCast(T)() const if (T == Legacy16Color)
    {
        return this.color;
    }
}

struct OnRGBColorType(uint8_t r, uint8_t g, uint8_t b)
{
    OnRGBColor color;
    alias color this;

    this()
    {
        color = OnRGBColor(r, g, b);
    }

    OnRGBColor opCast(T)() const if (T == OnRGBColor)
    {
        return color;
    }
}

// Platform specialize

version (Windows)
{
    private WORD ansiToWindowsColor(int code, WORD current)
    {
        static const ushort[8] ansi_map = [
            0, // black
            4, // red
            2, // green
            6, // yellow
            1, // blue
            5, // magenta
            3, // cyan
            7, // white
        ];

        if (code == 0)
        {
            return FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        }

        if (code >= 30 && code <= 37)
        {
            int index = code - 30;
            return cast(WORD)((current & 0xFFF0) | ansi_map[index]);
        }
        else if (code >= 90 && code <= 97)
        {
            int index = code - 90;
            return cast(WORD)((current & 0xFFF0) | ansi_map[index] | FOREGROUND_INTENSITY);
        }

        if (code >= 40 && code <= 47)
        {
            int index = code - 40;
            return cast(WORD)((current & 0xFF0F) | (ansi_map[index] << 4));
        }
        else if (code >= 100 && code <= 107)
        {
            int index = code - 100;
            WORD bg = cast(WORD)((ansi_map[index] | FOREGROUND_INTENSITY) << 4);
            return cast(WORD)((current & 0xFF0F) | bg);
        }

        return cast(WORD) current;
    }
}

private bool detectRGB(File stream)
{
    version (Windows)
    {
        HANDLE hConsole = stream.windowsHandle();
        if (hConsole == INVALID_HANDLE_VALUE)
            return false;

        DWORD dwMode = 0;
        if (!GetConsoleMode(hConsole, &dwMode))
            return false;

        dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
        if (!SetConsoleMode(hConsole, dwMode))
            return false;
    }
    return .isatty(stream);
}

private void setColorByANSI(File stream, RGBColor c, bool isBackground)
{
    auto mode = isBackground ? "\033[48;2;" : "\033[38;2;";
    stream.write(mode, c.r, ";", c.g, ";", c.b, "m");
}

private void setColorByAPI(File stream, Legacy16Color c)
{
    version (Posix)
    {
        stream.write("\x1b[", c.color, "m");
    }
    else version (Windows)
    {
        HANDLE hConsole = stream.windowsHandle();

        CONSOLE_SCREEN_BUFFER_INFO csbi;
        if (!GetConsoleScreenBufferInfo(hConsole, &csbi))
            return;

        WORD current = csbi.wAttributes;
        WORD color = ansiToWindowsColor(c.color, current);

        SetConsoleTextAttribute(hConsole, color);
    }
}

@property
File setColor(File stream, RGBColor c)
{
    if (!detectRGB(stream))
        return stream;

    setColorByANSI(stream, c, false);

    return stream;
}

@property
File setColor(File stream, Legacy16Color c)
{
    setColorByAPI(stream, c);

    return stream;
}

@property
File setColor(File stream, OnRGBColor c)
{
    if (!detectRGB(stream))
        return stream;

    setColorByANSI(stream, c.color, true);

    return stream;
}

private string createLegacyColor(string name, int n)
{
    string getUpperName()
    {
        return (cast(char) toUpper(name[0])) ~ name[1 .. $];
    }

    string color = "@property\n" ~
        "Legacy16Color " ~ name ~ "() { return Legacy16Color(" ~ n.to!string ~ "); }\n";

    string onColor = "@property\n" ~
        "Legacy16Color on" ~ getUpperName() ~ "() { return Legacy16Color(" ~ (n + 10)
        .to!string ~ "); }\n";

    string brightColor = "@property\n" ~
        "Legacy16Color bright" ~ getUpperName() ~ "() { return Legacy16Color(" ~ (n + 60)
        .to!string ~ "); }\n";

    string onBrightColor = "@property\n" ~
        "Legacy16Color onBright" ~ getUpperName() ~ "() { return Legacy16Color(" ~ (n + 70)
        .to!string ~ "); }\n";

    return color ~ onColor ~ brightColor ~ onBrightColor;
}

private string createLegacyStyle(string name, int n)
{
    return "@property\n"
        ~ "Legacy16Color " ~ name ~ "() { return Legacy16Color(" ~ n.to!string ~ "); }\n";
}

// Legacy16 color definations

mixin(createLegacyColor("reset", 0));
mixin(createLegacyColor("grey", 30));
mixin(createLegacyColor("red", 31));
mixin(createLegacyColor("green", 32));
mixin(createLegacyColor("yellow", 33));
mixin(createLegacyColor("blue", 34));
mixin(createLegacyColor("magenta", 35));
mixin(createLegacyColor("cyan", 36));
mixin(createLegacyColor("white", 37));
mixin(createLegacyStyle("bold", 1));
mixin(createLegacyStyle("dark", 2));
mixin(createLegacyStyle("italic", 3));
mixin(createLegacyStyle("underline", 4));
mixin(createLegacyStyle("blink", 5));
mixin(createLegacyStyle("reverse", 7));
mixin(createLegacyStyle("concealed", 8));
mixin(createLegacyStyle("crossed", 9));
