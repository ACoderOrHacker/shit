/++
 + The shit.command package
 + Defines Command structure to storage information of a command
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module shit.command;
@safe:
export:

import std.array;
import std.conv : to;
public import shit.command.parser;

/++ 
 + The specialize begin of commands
 +/
enum SystemCommandStartsWith = '%',
    NonSystemCommandStartsWith = '@';

/++ 
 + Commands type
 +/
enum CommandType
{
    System,
    NonSystem,
    Auto
}

/++
 + Command structure, defines information of a command
 +/
struct Command
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
        string name = this.name;
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

    export this(string fullOfCommand,
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

    /++ 
     + Get the program name
     + Returns: The program name, returns "" on failed
     +/
    @property
    string name() const
    {
        return commandList.length > 0 ? commandList[0] : "";
    }

    /++ 
     + Get the arguments
     + Returns: The arguments
     +/
    @property
    auto args() const
    {
        return commandList.length > 1 ? commandList[1 .. $] : [];
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

@system @("command") unittest
{
    auto c1 = Command(null);
    auto c2 = Command("echo arg");
    auto c3 = Command("echo arg1 arg2");
    auto c4 = Command("#");

    assert(c4.name == "");
    assert(c1.name == "");
    assert(c2.name == "echo");

    assert(c4.args == []);
    assert(c1.args == []);
    assert(c3.args == ["arg1", "arg2"]);
}
