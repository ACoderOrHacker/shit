module shit.main;

import std.file;
import std.path;
import std.stdio;
import std.format;
import std.algorithm : startsWith, endsWith;
import shit.helper.paths;
import shit.helper.title;
import shit.helper.exit;
import shit.helper.string;
import shit.configs.project;
import shit.configs.global;
import shit.initializer;
import shit.executor;
import shit.command;

void setDefaultTitle() {
    setConsoleTitle(format("SHIT shell v%s", shitFullVersion));
}

void executeCmdLine(ref GlobalConfig config, string home) {
    string path = getcwd();
    path = replaceFirst(path, home, "~");
    writef("%s $ ", path);

    // Read command from stdin
    string command = stdin.readln();
    if (command is null || command == "\n")
        return;

    setConsoleTitle(command);
    try {
        auto result = executeCommand(config, command);
        if (config.showExitCode) writefln("shit: exit code %s", result.getExitCode());
    } catch (ExecuteException e) {
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

    GlobalConfig globalConfig;
    string home = getHome();
    if (home.endsWith(dirSeparator)) {
        home = home[0 .. $ - dirSeparator.length]; // split dir separator
    }
    try {
        globalConfig = getGlobalConfig();
        startUp(globalConfig);
    } catch (BadGlobalConfigException e) {
        writefln("shit: startup error(bad global configures): %s", e.msg);
        globalConfig.showExitCode = false;
        globalConfig.defaultPath = home;
    } catch (GlobalConfigNotFoundException e) {
        writefln("shit: warning: global configures not found: %s", e.msg);
        globalConfig.showExitCode = false;
        globalConfig.defaultPath = home;
    } catch (StartUpException e) {
        writefln("shit: startup error(bad configures): %s", e.msg);
        globalConfig.showExitCode = false;
        globalConfig.defaultPath = home;
    }
    
    setDefaultTitle();
    try {
        while (true) {
            executeCmdLine(globalConfig, home);
        }
    } catch (ExitSignal e) {
        return e.getCode(); // exit
    }

    return 0;
}