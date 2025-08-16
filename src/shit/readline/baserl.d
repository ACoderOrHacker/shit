module shit.readline.baserl;

import std.stdio : File, stdin;
import shit.readline.readchar;
import shit.readline.inevent;

export class Readline
{
protected:
    dstring result;
    dchar iterator;
    InputEvent event;
    File stream;
    ConsoleReader reader;

    /// Configs
    void enterReadline()
    {
    }

    void exitReadline()
    {
    }

    void byChar()
    {
    }

    void typingCommand()
    {
    }

    void insertChar()
    {
    }

    bool onEvent()
    {
        return true;
    }

public:
    this(File stream)
    {
        this.stream = stream;
        reader = new ConsoleReader;
    }

    dstring read(File stream = stdin,
        VirtualKey endKey = VirtualKey.Enter)
    {
        enterReadline();
        scope (exit)
            exitReadline();
        while (true)
        {
            auto result = reader.read();
            iterator = result.utf32char;
            event = result.event;

            if ((!event.isPrintableAscii) && event.vkey != VirtualKey.None && event.vkey != endKey)
            {
                if (!onEvent())
                    continue;
            }

            if (iterator == endKey)
                break;

            byChar();
            insertChar();

            typingCommand();
        }

        return result;
    }
}
