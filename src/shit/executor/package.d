module executor;

import std.stdio;
import std.array;
import std.process;
import shit.command;
import shit.configs.global;

alias executeCommandType = ExecuteResult function(ref GlobalConfig, string[]);
alias builtinCommandsType = executeCommandType[string];

shared builtinCommandsType builtinCommands;

ref shared(builtinCommandsType) getBuiltinCommands() {
    return builtinCommands;
}

class ExecuteException : Exception {
    @safe
    this(string message,
        File stderr = stderr, 
        File stdout = stdout) {
        super(message);
        this.stderr = stderr;
        this.stdout = stdout;
    }

    @safe
    const(File) getStderr() const {
        return stderr;
    }

    @safe
    const(File) getStdout() const {
        return stdout;
    }

    File stderr;
    File stdout;
}

class RegisteredCommandNotFoundException : Exception {
	this(string msg) {
		super(msg);
	}
}

struct ExecuteResult {

    @safe
    this(int exit_code) {
        this.exit_code = exit_code;
    }

    @safe
    const(int) getExitCode() const {
        return exit_code;
    }

    int exit_code;
}

ExecuteResult executeProcess(Command cmd, 
    File err = stderr, File output = stdout) {
    scope(failure) throw new ExecuteException("failed from executeProcess",
        err, output);


    auto pid = spawnProcess(cmd.commandList, stdin, output, err);
    auto result = ExecuteResult(pid.wait());
    return result;
}

ExecuteResult executeProcess(string cmd) {
    return executeProcess(Command(cmd));
}

ExecuteResult executeCommand(ref GlobalConfig config, Command command) {
    string program = command.commandList[0];

	if (command.type == CommandType.System) {
		return executeProcess(command);
	} else if (command.type == CommandType.NonSystem) {
		if (program in getBuiltinCommands()) {
			return getBuiltinCommands()[program](config, command.commandList);
		} else {
			throw new RegisteredCommandNotFoundException("command " ~ program ~ "not found");
		}
    } else {
		// Auto type
		if (program in getBuiltinCommands()) {
			return getBuiltinCommands()[program](config, command.commandList);
		} else {
			return executeProcess(command);
		}
	}
}