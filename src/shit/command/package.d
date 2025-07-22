module shit.command;

import std.array;

enum
	SystemCommandStartsWith = '%',
	NonSystemCommandStartsWith = '@';

enum CommandType {
	System,
	NonSystem,
	Auto
}

struct Command {
    @safe
    pure nothrow this(string fullCommand) {
        this.full = fullCommand;
        this.commandList = splitCommand(fullCommand);
		char startsOfCommandName = commandName(this)[0];
		if (startsOfCommandName == SystemCommandStartsWith) {
			this.type = CommandType.System;
			commandList[0] = commandList[0][1 .. $];
		} else if (startsOfCommandName == NonSystemCommandStartsWith) {
			this.type = CommandType.NonSystem;
			commandList[0] = commandList[0][1 .. $];
		} else {
			this.type = CommandType.Auto;
		}
    }

    string full;
    string[] commandList;
	CommandType type;
	
}

@safe
extern (C)
pure nothrow string commandName(ref Command cmd) {
    return cmd.commandList.length > 0 ? cmd.commandList[0] : "";
}

@safe
extern (C)
pure nothrow string[] commandArgs(ref Command cmd) {
    return cmd.commandList.length > 1 ? cmd.commandList[1..$] : [];
}

@safe
extern (C)
private pure nothrow string[] splitCommand(string fullCommand) {
    return fullCommand.replace("\n", "").split(" ");
}