module shit.readline;

import std.stdio;
import std.ascii;
import shit.command;
import shit.command.parser;
import shit.helper.console;

alias enterCommandProcessType = void delegate(File);
alias exitCommandProcessType = void delegate(File, string);
alias byCharProcessType = void delegate(File, utf8char);
alias eachLoopProcessType = void delegate(File);
alias typingCommandProcessType = void delegate(File, string);
alias controlCharProcessType = bool delegate(File, ref string, char);
alias analyzeCommandProcessType = void delegate(File, Command);
alias insertCharProcessType = void delegate(ref string, utf8char);

class ReadlineConfig
{
    enterCommandProcessType enterCommand; // run when enter command input
    exitCommandProcessType exitCommand; // run when exit command input
    byCharProcessType byChar; // run when anything done, then get a character to output, etc
    eachLoopProcessType eachLoop; // run when each loop's begining
    typingCommandProcessType typingCommand; // run when typing command
    controlCharProcessType controlChar; // run when meet a control character, if returns false, then continue to next character
    analyzeCommandProcessType analyzeCommand; // run after parsing command (if the command is not valid, readline will not invoke it)
    insertCharProcessType insertChar;

    this()
    {
        enterCommand = delegate(File) {};
        exitCommand = delegate(File, string) {};
        byChar = delegate(File, utf8char) {};
        eachLoop = delegate(File) {};
        typingCommand = delegate(File, string) {};
        controlChar = delegate(File, ref string, char) { return false; };
        analyzeCommand = delegate(File, Command) {};
        insertChar = delegate(ref string s, utf8char c) { s ~= c; };
    }

    ReadlineConfig setEnterCommand(enterCommandProcessType process)
    {
        this.enterCommand = process;

        return this;
    }

    ReadlineConfig setExitCommand(exitCommandProcessType process)
    {
        this.exitCommand = process;

        return this;
    }

    ReadlineConfig setByChar(byCharProcessType process)
    {
        this.byChar = process;

        return this;
    }

    ReadlineConfig setEachLoop(eachLoopProcessType process)
    {
        this.eachLoop = process;

        return this;
    }

    ReadlineConfig setTypingCommand(typingCommandProcessType process)
    {
        this.typingCommand = process;

        return this;
    }

    ReadlineConfig setControlChar(controlCharProcessType process)
    {
        this.controlChar = process;

        return this;
    }

    ReadlineConfig setAnalyzeCommand(analyzeCommandProcessType process)
    {
        this.analyzeCommand = process;

        return this;
    }

    ReadlineConfig setInsertChar(insertCharProcessType process)
    {
        this.insertChar = process;

        return this;
    }
}

string readline(File stream = stdin,
    utf8char end = "\n",
    ReadlineConfig config)
{
    string result;

    bool isCommand = true; // at first, the input is the command
    bool entered = false, exited = false;
    utf8char c;
    while (true)
    {
        c = readUtf8Char();
        if (c == end)
            break;

        config.byChar(stream, c);

        if (c.length == 1 && isControl(c[0]))
        {
            if (!config.controlChar(stream, result, c[0]))
                continue;
        }

        config.eachLoop(stream);
        if (isCommand && !entered)
        {
            config.enterCommand(stream);
            entered = true;
        }

        config.insertChar(result, c);

        config.typingCommand(stream, result);

        Command parsedCommand;
        try
        {
            parsedCommand = Command(result);
        }
        catch (ParseError)
        {
            // user is typing the command
            // but we can't analyze anything
            // so do nothing
            continue;
        }

        config.analyzeCommand(stream, parsedCommand);

        if (parsedCommand.commandList.length > 1 && !exited)
        {
            config.exitCommand(stream, result);
            isCommand = false;
            exited = true;
        }

    }

    try
    {
        if (Command(result).commandList.length == 1 && !exited)
        {
            config.exitCommand(stream, result); // be sure that exitCommand always works
        }
    }
    catch (ParseError)
    {
    }

    return result;
}
