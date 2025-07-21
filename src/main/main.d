module shit.main;

import std.file;
import std.stdio;
import std.format;
import std.algorithm : startsWith;
import shit.helper.paths;
import shit.helper.title;
import shit.helper.exit;
import shit.configs.project;
import shit.initializer;
import shit.executor;
import shit.command;

void setDefaultTitle() {
    setConsoleTitle(format("SHIT shell v%s", shitFullVersion));
}

void executeCmdLine(string home) {
    string path = getcwd();
    if (path.startsWith(home)) {
        path = path[home.length .. $];
        if (path == "") path = "~"; // root
    }
    writef("%s $ ", path);

    // Read command from stdin
    string command = stdin.readln();
    if (command is null || command == "\n")
        return;

    setConsoleTitle(command);
    try {
        auto result = executeCommand(command);
        writefln("shit: exit code %s", result.getExitCode());
    } catch (ExecuteError e) {
        Command cmd = Command(command);
        writefln("shit: %s: command not found", commandName(cmd));
    }
    setDefaultTitle();
}

int main() {
    // output information
    writefln("SHIT shell v%s, a powerful and modern terminal", shitFullVersion);
    writefln("On [%s, %s], on %s mode",
        shitOs, shitArchitecture, shitMode);
    writeln("Copyright (C) 2025, ACoderOrHacker");
    writeln();

    try {
        startUp();
    } catch (StartUpException e) {
        writefln("shit: startup error(bad configures): %s", e.msg);
    }

    setDefaultTitle();
    string home = getHome();
    try {
        while (true) {
            executeCmdLine(home);
        }
    } catch (ExitSignal e) {
        return e.getCode(); // exit
    }

    return 0;
}