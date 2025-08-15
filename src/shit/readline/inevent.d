module shit.readline.inevent;

import std.stdint;

version (Posix)
{
    import core.sys.posix;

    struct PlatformEvent
    {
        string code; // ansi escape sequence
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
        InputEvent readPosixEvent()
        {
            ubyte[8] buffer;
            InputEvent event;

            read(0, buffer.ptr, 1);
            event.raw.code[0] = cast(char) buffer[0];

            if (buffer[0] == 0x1B) // ESC
            {
                timeval timeout = [0, 100000]; // 100ms
                fd_set fds;
                FD_ZERO(&fds);
                FD_SET(0, &fds);

                int i = 1;
                for (; i < 8; i++)
                {
                    if (select(1, &fds, null, null, &timeout) <= 0)
                        break;

                    read(0, buffer.ptr + i, 1);

                    if (buffer[i] >= 0x40 && buffer[i] <= 0x7E)
                        break;
                }
            }

            event.raw = cast(string) buffer[0 .. i];
            parsePosixEvent(buffer[0 .. i], event);
            return event;
        }

        void parsePosixEvent(const(ubyte)[] seq, ref InputEvent event)
        {
            event.vkey = VKey.None;

            if (seq.length == 1)
            {
                if (seq[0] >= 32 && seq[0] <= 126)
                {
                    event.vkey = cast(VKey) seq[0];
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
                        event.vkey = VKey.Up;
                        break;
                    case "B":
                        event.vkey = VKey.Down;
                        break;
                    case "C":
                        event.vkey = VKey.Right;
                        break;
                    case "D":
                        event.vkey = VKey.Left;
                        break;
                    case "H":
                        event.vkey = VKey.Home;
                        break;
                    case "F":
                        event.vkey = VKey.End;
                        break;
                    case "5~":
                        event.vkey = VKey.PageUp;
                        break;
                    case "6~":
                        event.vkey = VKey.PageDown;
                        break;
                    case "2~":
                        event.vkey = VKey.Insert;
                        break;
                    case "3~":
                        event.vkey = VKey.Delete;
                        break;
                    case "P":
                        event.vkey = VKey.F1;
                        break;
                    case "Q":
                        event.vkey = VKey.F2;
                        break;
                    case "R":
                        event.vkey = VKey.F3;
                        break;
                    case "S":
                        event.vkey = VKey.F4;
                        break;
                    case "11~":
                        event.vkey = VKey.F1;
                        break;
                    case "12~":
                        event.vkey = VKey.F2;
                        break;
                    case "13~":
                        event.vkey = VKey.F3;
                        break;
                    case "14~":
                        event.vkey = VKey.F4;
                        break;
                    case "15~":
                        event.vkey = VKey.F5;
                        break;
                    case "17~":
                        event.vkey = VKey.F6;
                        break;
                    case "18~":
                        event.vkey = VKey.F7;
                        break;
                    case "19~":
                        event.vkey = VKey.F8;
                        break;
                    case "20~":
                        event.vkey = VKey.F9;
                        break;
                    case "21~":
                        event.vkey = VKey.F10;
                        break;
                    case "23~":
                        event.vkey = VKey.F11;
                        break;
                    case "24~":
                        event.vkey = VKey.F12;
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
                    event.vkey = cast(VKey) seq[1];
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
