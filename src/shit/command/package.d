module shit.command;

import std.array;

struct Command {
    @safe
    pure nothrow this(string fullCommand) {
        this.full = fullCommand;
        this.command_list = splitCommand(fullCommand);
    }

    string full;
    string[] command_list;
}

@safe
extern (C)
pure nothrow string commandName(Command cmd) {
    return cmd.command_list.length > 0 ? cmd.command_list[0] : "";
}

@safe
extern (C)
pure nothrow string[] commandArgs(Command cmd) {
    return cmd.command_list.length > 1 ? cmd.command_list[1..$] : [];
}

@safe
extern (C)
private pure nothrow string[] splitCommand(string fullCommand) {
    return fullCommand.replace("\n", "").split(" ");
}