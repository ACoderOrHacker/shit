module executor;

import std.stdio;
import std.array;
import std.process;
import shit.command;
import shit.configs.global;

alias executeCommandType = ExecuteResult delegate(ref GlobalConfig, string[]);
alias executeCommandFunctionType = ExecuteResult function(ref GlobalConfig, string[]);
alias builtinCommandsType = executeCommandType[string];

shared builtinCommandsType builtinCommands;

ref shared(builtinCommandsType) getBuiltinCommands() {
    return builtinCommands;
}

class Registry {
    Registry register(string name, executeCommandType command) {
        getBuiltinCommands()[name] = command;
        return this;
    }

    Registry register(string name, executeCommandFunctionType command) {
        import std.functional : toDelegate;
        getBuiltinCommands()[name] = toDelegate(command);
        return this;
    }
}

@("registry") unittest {
    assert(&getBuiltinCommands() == &builtinCommands);
    auto r = new Registry;

    ExecuteResult t(ref GlobalConfig, string[]) {
        return ExecuteResult(0);
    }
    r.register("test1", &t);
    r.register("test2", &t);

    auto c = getBuiltinCommands();

    assert("test1" in c, "Failed write `test1` to registry");
    assert("test2" in c, "Failed write `test2` to registry");
}

class ExecuteException : Exception {
    @safe
    this(string msg) {
        super(msg);
    }
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
    scope(failure) throw new ExecuteException(commandName(cmd) ~ ": command not found");

    auto pid = spawnProcess(cmd.commandList, stdin, output, err);
    auto result = ExecuteResult(pid.wait());
    return result;
}

ExecuteResult executeNonSystem(Command cmd, ref GlobalConfig config) {
    auto builtins = getBuiltinCommands();
    string prog = commandName(cmd);
    if (prog !in builtins)
        throw new RegisteredCommandNotFoundException("command `" ~ prog ~ "` not found");

    return getBuiltinCommands()[prog](config, cmd.commandList);
}

ExecuteResult executeCommand(ref GlobalConfig config, Command command) {
	if (command.type == CommandType.System) {
		return executeProcess(command);
	} else if (command.type == CommandType.NonSystem) {
		return executeNonSystem(command, config);
    } else {
		// Auto type
		if (commandName(command) in getBuiltinCommands()) {
            return executeNonSystem(command, config);
        } else {
            return executeProcess(command);
        }
	}
}