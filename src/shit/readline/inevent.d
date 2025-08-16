module shit.readline.inevent;

import std.stdint;
import std.ascii : isAlpha;
import std.conv : to;

version (Posix)
{
    import core.sys.posix.unistd;
    import core.sys.posix.sys.select;

    struct PlatformEvent
    {
        char[] code; // ansi escape sequence
    }
}
else version (Windows)
{
    import core.sys.windows.windows;

    alias PlatformEvent = INPUT_RECORD;
}
else
{
    static assert(false, "Unsupported platform");
}

enum VirtualKey : uint16_t
{
    None = 0,
    Backspace = 8,
    Tab = 9,
    Enter = 13,
    Shift = 16,
    Control = 17,
    Alt = 18,
    Escape = 27,
    Space = 32,

    F1 = 127,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    F13,
    F14,
    F15,
    F16,
    F17,
    F18,
    F19,
    F20,
    F21,
    F22,
    F23,
    F24,

    PageUp,
    PageDown,
    End,
    Home,
    Left,
    Up,
    Right,
    Down,
    Insert,
    Delete,

    CapsLock = 0x1010,
    NumLock,
    ScrollLock
}

export struct InputEvent
{
    VirtualKey vkey;
    PlatformEvent raw; // raw event

    @property
    bool isPrintableAscii() const
    {
        return (cast(uint16_t) vkey) >= 32 && (cast(uint16_t) vkey) <= 126;
    }

    @property
    char ascii() const
    {
        return cast(char) vkey;
    }
}

export class EventReader
{
    InputEvent read()
    {
        version (Posix)
            return readPosixEvent();
        version (Windows)
            return readWindowsEvent();
    }

private:
    version (Posix)
    {
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
                if (!.read(STDIN_FILENO, &ch, 1))
                    break;

                if (buffer.length < (pos + 2)) // actually, it's (buffer.length - 1) < (pos+ 1)
                    buffer.length = (buffer.length * 1.5).to!ulong; // length *= 1.5

                if (isAlpha(ch) || ch == '~' || ch == '\x07')
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

            return cast(string) buffer[0 .. pos].idup;
        }

        InputEvent readPosixEvent()
        {
            ubyte[] buffer;
            InputEvent event;

            buffer.length = 8;

            

            .read(0, buffer.ptr, 1);
            event.raw.code.length = 1;
            event.raw.code[0] = cast(char) buffer[0];

            if (buffer[0] == 0x1B) // ESC
            {
                event.raw.code = readEscapeSequence().dup;
            }

            parsePosixEvent(cast(const(ubyte)[]) event.raw.code, event);
            return event;
        }

        void parsePosixEvent(const(ubyte)[] seq, ref InputEvent event)
        {
            event.vkey = VirtualKey.None;

            if (seq.length == 1)
            {
                if (seq[0] >= 32 && seq[0] <= 126)
                {
                    event.vkey = cast(VirtualKey) seq[0];
                }
                switch (seq[0])
                {
                case 0x08:
                case 0x7F:
                    event.vkey = VirtualKey.Backspace;
                    break;
                case 0x09:
                    event.vkey = VirtualKey.Tab;
                    break;
                case 0x0A:
                case 0X0D:
                    event.vkey = VirtualKey.Enter;
                    break;
                default:
                    event.vkey = cast(VirtualKey) seq[0];
                    break;
                }
                return;
            }

            if (seq[0] == 0x1B)
            {
                if (seq[1] == '[' || seq[1] == 'O')
                {
                    string s = cast(string) seq[2 .. $];
                    switch (s)
                    {
                    case "A":
                        event.vkey = VirtualKey.Up;
                        break;
                    case "B":
                        event.vkey = VirtualKey.Down;
                        break;
                    case "C":
                        event.vkey = VirtualKey.Right;
                        break;
                    case "D":
                        event.vkey = VirtualKey.Left;
                        break;
                    case "H":
                        event.vkey = VirtualKey.Home;
                        break;
                    case "F":
                        event.vkey = VirtualKey.End;
                        break;
                    case "5~":
                        event.vkey = VirtualKey.PageUp;
                        break;
                    case "6~":
                        event.vkey = VirtualKey.PageDown;
                        break;
                    case "2~":
                        event.vkey = VirtualKey.Insert;
                        break;
                    case "3~":
                        event.vkey = VirtualKey.Delete;
                        break;
                    case "P":
                        event.vkey = VirtualKey.F1;
                        break;
                    case "Q":
                        event.vkey = VirtualKey.F2;
                        break;
                    case "R":
                        event.vkey = VirtualKey.F3;
                        break;
                    case "S":
                        event.vkey = VirtualKey.F4;
                        break;
                    case "11~":
                        event.vkey = VirtualKey.F1;
                        break;
                    case "12~":
                        event.vkey = VirtualKey.F2;
                        break;
                    case "13~":
                        event.vkey = VirtualKey.F3;
                        break;
                    case "14~":
                        event.vkey = VirtualKey.F4;
                        break;
                    case "15~":
                        event.vkey = VirtualKey.F5;
                        break;
                    case "17~":
                        event.vkey = VirtualKey.F6;
                        break;
                    case "18~":
                        event.vkey = VirtualKey.F7;
                        break;
                    case "19~":
                        event.vkey = VirtualKey.F8;
                        break;
                    case "20~":
                        event.vkey = VirtualKey.F9;
                        break;
                    case "21~":
                        event.vkey = VirtualKey.F10;
                        break;
                    case "23~":
                        event.vkey = VirtualKey.F11;
                        break;
                    case "24~":
                        event.vkey = VirtualKey.F12;
                        break;
                    default:
                        break;
                    }
                }
            }
            else if (seq.length == 2)
            {
                if (seq[1] >= 32 && seq[1] <= 126)
                {
                    event.vkey = cast(VirtualKey) seq[1];
                }
            }
        }
    }
    version (Windows)
    {
        InputEvent readWindowsEvent()
        {
            HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);
            INPUT_RECORD record;
            DWORD count;

            while (true)
            {
                ReadConsoleInputA(hInput, &record, 1, &count);
                if (count == 0 || record.EventType != KEY_EVENT)
                    continue;

                auto keyEvent = record.KeyEvent;
                if (!keyEvent.bKeyDown)
                    continue;

                InputEvent event;
                event.raw = record;
                event.vkey = translateWinKey(keyEvent.wVirtualKeyCode, keyEvent
                        .uChar.UnicodeChar);

                if (event.vkey != VirtualKey.None)
                    return event;
            }
        }

        version (Windows) VirtualKey translateWinKey(uint16_t vk, wchar ch)
        {
            if (vk >= 0x70 && vk <= 0x87)
                return cast(VirtualKey)(VirtualKey.F1 + (vk - 0x70));

            switch (vk)
            {
            case 0x08:
                return VirtualKey.Backspace;
            case 0x09:
                return VirtualKey.Tab;
            case 0x0D:
                return VirtualKey.Enter;
            case 0x1B:
                return VirtualKey.Escape;
            case 0x20:
                return VirtualKey.Space;
            case 0x21:
                return VirtualKey.PageUp;
            case 0x22:
                return VirtualKey.PageDown;
            case 0x23:
                return VirtualKey.End;
            case 0x24:
                return VirtualKey.Home;
            case 0x25:
                return VirtualKey.Left;
            case 0x26:
                return VirtualKey.Up;
            case 0x27:
                return VirtualKey.Right;
            case 0x28:
                return VirtualKey.Down;
            case 0x2D:
                return VirtualKey.Insert;
            case 0x2E:
                return VirtualKey.Delete;
            case 0x14:
                return VirtualKey.CapsLock;
            case 0x90:
                return VirtualKey.NumLock;
            case 0x91:
                return VirtualKey.ScrollLock;
            case 0x10:
                return VirtualKey.Shift;
            case 0x11:
                return VirtualKey.Control;
            case 0x12:
                return VirtualKey.Alt;
            default:
                break;
            }

            if (ch >= 32 && ch <= 126)
                return cast(VirtualKey) ch;

            return VirtualKey.None;
        }
    }
}
