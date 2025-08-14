module shit.readline.rldefault;

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
    string indicator;
    ulong beforeCursorDcharCount;

public:
    export this(string indicator)
    {
        beforeCursorDcharCount = 0;
        controler = new Cbreak;
        this.indicator = indicator;
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
            foreach (_; 0 .. wcwidth(super.result[beforeCursorDcharCount - 1]))
            {
                stderr.write("\x1b[D\x1b[P");
            }
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

        stderr.write("\x1b[0m");
        stderr.write("\r");
        stderr.write("\x1b[" ~ wswidth(indicator).to!string ~ "C");
        stderr.write("\x1b[0K");
        stderr.write(color, super.result, "\x1b[0m");
        long backn = wswidth(super.result[beforeCursorDcharCount .. $]);

        if (backn != 0)
            stderr.write("\x1b[" ~ backn.to!string ~ "D");
        stderr.flush();
    }
}
