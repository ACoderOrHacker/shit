module executor;

import std.stdio;
import std.array;
import std.process;
import shit.command;

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
    this(int exit_code, 
        File stderr = stderr, 
        File stdout = stdout) {
        this.exit_code = exit_code;
        this.stderr = stderr;
        this.stdout = stdout;
    }

    @safe
    const(int) getExitCode() const {
        return exit_code;
    }

    @safe
    const(File) getStderr() const {
        return stderr;
    }

    @safe
    const(File) getStdout() const {
        return stdout;
    }

    int exit_code;
    File stderr;
    File stdout;
}


ExecuteResult executeProcess(Command cmd, 
    File err = stderr, File output = stdout) {
    scope(failure) throw new ExecuteError("failed from executeProcess",
        err, output);


    auto pid = spawnProcess(cmd.command_list, stdin, output, err);
    auto result = ExecuteResult(pid.wait(), err, output);
    return result;
}

void executeProcess(string cmd) {
    executeProcess(Command(cmd));
}

extern(C) int executor() {
	return 0;
}