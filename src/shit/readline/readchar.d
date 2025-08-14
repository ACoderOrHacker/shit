module shit.readline.readchar;

import std.typecons : Tuple;
import std.format;
import std.utf : decode;
import shit.readline.inevent;

version (Posix)
{
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

export class ReadCharException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

private int utf8CharLength(ubyte firstByte)
{
    if ((firstByte & 0x80) == 0x00)
    { // 0xxxxxxx
        return 1;
    }
    else if ((firstByte & 0xE0) == 0xC0)
    { // 110xxxxx
        return 2;
    }
    else if ((firstByte & 0xF0) == 0xE0)
    { // 1110xxxx
        return 3;
    }
    else if ((firstByte & 0xF8) == 0xF0)
    { // 11110xxx
        return 4;
    }
    else
    {
        return -1;
    }
}

export class ConsoleReader
{
    private EventReader reader;

    this()
    {
        reader = new EventReader;
    }

    alias ReadResult = Tuple!(dchar, "utf32char", InputEvent, "event");

    ReadResult read()
    {
        InputEvent ev = reader.read();

        if (ev.vkey == VirtualKey.None)
        {
            throw new ReadCharException("failed read the utf-8 character");
        }

        if (!ev.isPrintableAscii) // maybe a control character
            return ReadResult(ev.ascii, ev);

        int charLen = utf8CharLength(ev.ascii);
        if (charLen < 1)
        {
            throw new ReadCharException(format("invalid utf-8 character code: 0x%02X", ev.ascii));
        }

        ubyte[4] buffer;
        buffer[0] = ev.ascii;
        int bytesRead = 1;
        while (bytesRead < charLen)
        {
            auto ch = reader.read();
            if (!ch.isPrintableAscii)
            {
                throw new ReadCharException("failed read the utf-8 character");
            }

            buffer[bytesRead] = ch.ascii;

            if ((buffer[bytesRead] & 0xC0) != 0x80)
            {
                throw new ReadCharException(format("invalid utf-8 character: 0x%02X", buffer[bytesRead]));
            }

            bytesRead++;
        }

        size_t tmp = 0;
        return ReadResult(decode(cast(char[]) buffer[0 .. charLen], tmp), ev);
    }
}
