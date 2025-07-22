module shit.command.builtins;

import std.file : chdir;
import std.stdio;
import std.conv;
import shit.executor;
import shit.configs.global;
import shit.helper.exit;

ExecuteResult builtinCd(ref GlobalConfig config, string[] args) {
    scope(failure) {
        writefln("cd: %s: No such file or directory", args[1]);
        return ExecuteResult(1);
    }
    if (args.length == 2) {
        chdir(args[1]);
    } else {
        writeln("Usage: cd <directory>");
    }

    return ExecuteResult(0);
}

ExecuteResult builtinExit(ref GlobalConfig config, string[] args) {
    if (args.length == 2) {
        exit(args[1].to!int);
    } else {
        exit(0);
    }

    return ExecuteResult(0);
}

static this() {
    getBuiltinCommands()["cd"] = &builtinCd;
    getBuiltinCommands()["exit"] = &builtinExit;
}