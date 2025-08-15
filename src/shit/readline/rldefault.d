module shit.readline.rldefault;

import std.stdint;
import std.stdio;
import std.string;
import std.conv : to;
import std.ascii : isGraphical;
import std.utf : toUTF8;
import std.algorithm.mutation : remove;
import std.array : array;
import std.exception;
import shit.command;
import shit.command.parser;
import shit.executor;
import shit.readline.cbreak;
import shit.readline.inevent;
import shit.readline.baserl;
import shit.readline.wcwidth;
import helper.str;

export class DefaultReadline : Readline
{
private:
    Cbreak controler;
    uint32_t beforeCursorDcharCount;
    uint32_t lastResultWidth;
    uint32_t lastAfterCursorWidth;

    void writeInfoOfLastResult()
    {
        lastResultWidth = wswidth(super.result);
        lastAfterCursorWidth = wswidth(super.result[beforeCursorDcharCount .. $]);
    }

public:
    export this()
    {
        beforeCursorDcharCount = 0;
        lastResultWidth = 0;
        lastAfterCursorWidth = 0;
        controler = new Cbreak;
        super(stdin);
    }

    override void enterReadline()
    {
        controler.cbreak();
    }

    override void exitReadline()
    {
        controler.restore();
    }

    override bool onEvent()
    {
        switch (event.vkey)
        {
        case VirtualKey.Left:
            if (beforeCursorDcharCount == 0)
                break;
            stderr.write("\x1b[D");
            stderr.flush();
            --beforeCursorDcharCount;
            break;
        case VirtualKey.Right:
            if (super.result.length - beforeCursorDcharCount == 0)
                break;
            stderr.write("\x1b[C");
            stderr.flush();
            ++beforeCursorDcharCount;
            break;
        case VirtualKey.Backspace:
            if (beforeCursorDcharCount == 0)
                break;
            writeInfoOfLastResult();
            super.result = cast(dstring)(cast(dchar[]) super.result)
                .remove(beforeCursorDcharCount - 1);
            --beforeCursorDcharCount;
            typingCommand();
            break;
        default:
            break;
        }

        return false;
    }

    override void insertChar()
    {
        writeInfoOfLastResult();
        super.result = insert(super.result, beforeCursorDcharCount, super.iterator);
        ++beforeCursorDcharCount;
    }

    override void typingCommand()
    {
        string color;
        try
        {
            Command cmd = Command(super.result.toUTF8);
            color = isValidCommand(cmd) ? "\x1b[32m" : "\x1b[31m";
        }
        catch (ParseError)
        {
            color = "\x1b[37m";
        }

        if (lastAfterCursorWidth != 0)
            stderr.write("\x1b[" ~ lastAfterCursorWidth.to!string ~ "C");
        foreach (_; 0 .. lastResultWidth)
        {
            stderr.write("\x1b[D\x1b[P");
        }
        stderr.write(color, super.result, "\x1b[0m");
        auto width = wswidth(super.result[beforeCursorDcharCount .. $]);
        if (width != 0)
            stderr.write("\x1b[" ~ width.to!string ~ "D");
        stderr.flush();
    }
}
