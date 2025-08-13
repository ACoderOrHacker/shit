module shit.readline.controlchar;

import std.conv : to;
import std.exception;
import std.stdio;
import std.algorithm : filter, splitter, map;
import std.string : strip;
import std.range : empty;
import std.array : array;
import shit.helper.console;
import shit.readline.events;

version (Posix)
{
    import core.sys.posix.termios;
    import core.sys.posix.unistd;
    import core.sys.posix.sys.select;
    import core.sys.posix.sys.time;
    import core.stdc.ctype;
}

class BadAnsiEscapeCodeException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

class UnknownEscaoeCodeException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

struct ConsoleInfo
{
    ulong cursorPos;
}

enum EscapeSequenceType
{
    CSI,
    OSC,
    ESC,
    OTHER
}

EscapeSequenceType getEscapeSeqType(string code)
{
    if (code.length < 2)
        throw new UnknownEscaoeCodeException("bad escape sequence");

    if (code[1] == '[')
        return EscapeSequenceType.CSI;
    else if (code[1] == ']' && (code[$ - 1] == '\x07' || (code[$ - 1] == '\\' && code[$ - 2] == '\x1b')))
        return EscapeSequenceType.OSC;
    else if (code.length == 2)
        return EscapeSequenceType.ESC;
    else
        return EscapeSequenceType.OTHER;
}

// TODO: add windows version

enum ESCAPE_TIMEOUT_MS = 50;

string readEscapeSequence()
{
    ubyte[] buffer;
    buffer.length = 8;
    ulong pos = 0;
    buffer[0] = '\x1b';
    ++pos;

    bool readOSCEscape = false;

    fd_set fds;
    timeval tv;

    while (true)
    {
        FD_ZERO(&fds);
        FD_SET(STDIN_FILENO, &fds);

        tv.tv_sec = 0;
        tv.tv_usec = ESCAPE_TIMEOUT_MS * 1000;

        if (select(STDIN_FILENO + 1, &fds, null, null, &tv) <= 0)
        {
            break;
        }

        ubyte ch;
        if (!readChar(&ch))
            break;

        if (buffer.length < (pos + 2)) // actually, it's (buffer.length - 1) < (pos+ 1)
            buffer.length = (buffer.length * 1.5).to!ulong; // length *= 1.5

        if (isalpha(ch) || ch == '~' || ch == '\x07')
        {
            buffer[pos] = ch;
            ++pos;
            break;
        }

        if (readOSCEscape && ch == '\\')
        {
            buffer[pos] = ch;
            ++pos;
            readOSCEscape = false; // actually, it has no effect because we jump out
            // just for something bad :)
            break;
        }

        if (ch == '\x1b')
        {
            readOSCEscape = true;
        }

        buffer[pos] = ch;

        pos++;
    }

    return cast(string) buffer[0 .. pos].dup;
}

Event processEscapeSequence(string codeInput)
in
{
    enforce(codeInput !is null);
    enforce(codeInput[0] == '\x1b');
}
body
{
    string code = codeInput.filter!(c => !isspace(c))
        .array
        .to!string;
    auto seqType = getEscapeSeqType(code);

    final switch (seqType)
    {
    case EscapeSequenceType.CSI:
        char commandOfSeq = code[$ - 1];
        string paramStr = code.length >= 3 ? cast(string) code[2 .. $ - 1].dup : "";
        auto params = paramStr.splitter(';')
            .map!(s => s.strip().empty ? "0" : s)
            .map!(to!int)
            .array;
        switch (commandOfSeq)
        {
        case 'h':
            return Event(ShowOrHidCursorEvent(true));
        case 'l':
            return Event(ShowOrHidCursorEvent(false));
        case 'K':
            char modeChar = code[$ - 1];
            ClearScreenMode mode = ClearScreenMode.FromCursorToLineTail;
            if (modeChar == '1')
            {
                mode = ClearScreenMode.FromCursorToLineHead;
            }
            else if (modeChar == '2')
            {
                mode = ClearScreenMode.AllLine;
            }

            return Event(ClearScreenEvent(mode));
        case 'J':
            char modeChar = code[$ - 1];
            ClearScreenMode mode = ClearScreenMode.FromCursorToScreenTail;
            if (modeChar == '1')
            {
                mode = ClearScreenMode.FromCursorToScreenHead;
            }
            else if (modeChar == '2')
            {
                mode = ClearScreenMode.All;
            }

            return Event(ClearScreenEvent(mode));
        case 's':
            return Event(SaveOrRestoreCursorPosEvent(true));
        case 'u':
            return Event(SaveOrRestoreCursorPosEvent(false));
        case 'A':
            if (params.length > 1)
                return Event(UnknownEvent(code));
            return Event(CursorMoveEvent(CursorMoveType.Up, params.length == 1 ? params[0] : 1));
        case 'B':
            if (params.length > 1)
                return Event(UnknownEvent(code));
            return Event(CursorMoveEvent(CursorMoveType.Down, params.length == 1 ? params[0] : 1));
        case 'C':
            if (params.length > 1)
                return Event(UnknownEvent(code));
            return Event(CursorMoveEvent(CursorMoveType.Right, params.length == 1 ? params[0] : 1));
        case 'D':
            if (params.length > 1)
                return Event(UnknownEvent(code));
            return Event(CursorMoveEvent(CursorMoveType.Left, params.length == 1 ? params[0] : 1));
        case 'm':
            TextStyleEvent styleEvent;
            if (params.length == 0)
            {
                styleEvent.modes.length = 1;
                styleEvent.modes[0] = 0;
            }
            else
            {
                styleEvent.modes = params.dup;
            }
            return Event(styleEvent);
        case 'H':
            CursorMovePosEvent movePosEvent;
            if (params.length == 0)
            {
                movePosEvent.col = 1;
                movePosEvent.row = 1;
            }
            else if (params.length == 1)
            {
                movePosEvent.row = params[0];
                movePosEvent.col = 1;
            }
            else if (params.length == 2)
            {
                movePosEvent.row = params[0];
                movePosEvent.col = params[1];
            }
            else
            {
                return Event(UnknownEvent(code));
            }

            return Event(movePosEvent);
        default:
            return Event(UnknownEvent(code));
        }
        break;
    case EscapeSequenceType.OSC:
        string details;
        if (code[$ - 1] == '\x07')
            details = code[2 .. $ - 1];
        else
            details = code[2 .. $ - 2]; // \x1b\
        switch (code[2])
        {
        case '0':
            return Event(WindowTitleEvent(details[2 .. $], false));
        case '2':
            return Event(WindowTitleEvent(details[2 .. $], true));
        case '8':
            HyperLinkEvent hyperLinkEvent;
            if (details.length < 3)
                return Event(UnknownEvent(code));
            hyperLinkEvent.hyperLink(details.length == 3 ? null : details[3 .. $]);
            return Event(hyperLinkEvent);
        default:
            return Event(UnknownEvent(code));
        }
        break;
    case EscapeSequenceType.ESC:
        switch (code[1])
        {
        case 'c':
            return Event(ResetConsoleEvent());
        case 'E':
            return Event(GotoNextLineHeadEvent());
        case 'M':
            return Event(ScrollUpCursorEvent());
        case '7':
            return Event(SaveOrRestoreCursorPosEvent(true));
        case '8':
            return Event(SaveOrRestoreCursorPosEvent(false));
        default:
            return Event(UnknownEvent(code));
        }
        break;
    case EscapeSequenceType.OTHER:
        return Event(UnknownEvent(code));
    }
}
