module shit.command;

import std.array;
import std.conv : to;
public import shit.command.parser;

enum SystemCommandStartsWith = '%',
    NonSystemCommandStartsWith = '@';

enum CommandType
{
    System,
    NonSystem,
    Auto
}

export struct Command
{
    export this(string fullCommand)
    {
        if (fullCommand is null)
        {
            this.full = "";
            this.commandList = [];
            this.type = CommandType.Auto;

            return;
        }

        this.full = fullCommand;
        this.commandList = splitCommand(fullCommand);
        string name = commandName(this);
        char startsOfCommandName = name.length == 0 ? 's' /* anything you want */  : name[0];
        if (startsOfCommandName == SystemCommandStartsWith)
        {
            this.type = CommandType.System;
            commandList[0] = commandList[0][1 .. $];
        }
        else if (startsOfCommandName == NonSystemCommandStartsWith)
        {
            this.type = CommandType.NonSystem;
            commandList[0] = commandList[0][1 .. $];
        }
        else
        {
            this.type = CommandType.Auto;
        }
    }

    this(string fullOfCommand,
        string[] commandListOfCommand,
        CommandType typeOfCommand)
    {
        this.full = fullOfCommand;
        this.commandList = commandListOfCommand;
        this.type = typeOfCommand;
    }

    string toString() const
    {
        string typestr;
        final switch (type)
        {
        case CommandType.System:
            typestr = "System";
            break;
        case CommandType.NonSystem:
            typestr = "NonSystem";
            break;
        case CommandType.Auto:
            typestr = "Auto";
            break;
        }
        return "{" ~ "full: " ~ full ~ ", " ~ "commandList: " ~ commandList.to!string ~
            ", " ~ "type: " ~ typestr ~ "}";
    }

    string full;
    string[] commandList;
    CommandType type;

    @system @("Command") unittest
    {
        string test1 = SystemCommandStartsWith ~ "echo test1",
        test2 = NonSystemCommandStartsWith ~ "echo test2",
        test3 = "echo test3";

        void check(string s, string[] l, CommandType t, string f = null)
        {
            Command c = Command(s);
            with (c)
            {
                assert(full == (f is null ? s : f) && commandList == l && type == t,
                    "Failed create Command(" ~ s ~ ")" ~
                        "\n  Expected: " ~ Command(f is null ? s : f, l, t).to!string ~
                        "\n  Got: " ~ c.to!string);
            }
        }

        check(test1, ["echo", "test1"], CommandType.System);
        check(test2, ["echo", "test2"], CommandType.NonSystem);
        check(test3, ["echo", "test3"], CommandType.Auto);
        check("", [], CommandType.Auto);
        check(null, [], CommandType.Auto, "");
    }
}

@safe
export pure nothrow string commandName(ref Command cmd)
{
    return cmd.commandList.length > 0 ? cmd.commandList[0] : "";
}

@safe
export pure nothrow string[] commandArgs(ref Command cmd)
{
    return cmd.commandList.length > 1 ? cmd.commandList[1 .. $] : [];
}

@system @("command") unittest
{
    auto c1 = Command(null);
    auto c2 = Command("echo arg");
    auto c3 = Command("echo arg1 arg2");
    auto c4 = Command("#");

    assert(commandName(c4) == "");
    assert(commandName(c1) == "");
    assert(commandName(c2) == "echo");

    assert(commandArgs(c4) == []);
    assert(commandArgs(c1) == []);
    assert(commandArgs(c3) == ["arg1", "arg2"]);
}
