module executor;

import std.stdio;
import std.array;
import std.process;
import shit.command;

alias executeCommandType = ExecuteResult function(string[]);
alias builtinCommandsType = executeCommandType[string];

shared builtinCommandsType builtinCommands;

ref shared(builtinCommandsType) getBuiltinCommands() {
    return builtinCommands;
}

class ExecuteError : Exception {
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
    scope(failure) throw new ExecuteError("failed from executeProcess",
        err, output);


    auto pid = spawnProcess(cmd.command_list, stdin, output, err);
    auto result = ExecuteResult(pid.wait());
    return result;
}

ExecuteResult executeProcess(string cmd) {
    return executeProcess(Command(cmd));
}

ExecuteResult executeCommand(string cmd) {
    Command command = Command(cmd);
    string program = command.command_list[0];

    if (program in getBuiltinCommands()) {
        return getBuiltinCommands()[program](command.command_list);
    }

    return executeProcess(command);
}