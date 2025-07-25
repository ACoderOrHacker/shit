module shit.main;

import std.file;
import std.path;
import std.stdio;
import std.format : format;
import std.conv : to;
import std.algorithm : startsWith, endsWith;
import shit.helper;
import shit.configs.project;
import shit.configs.global;
import shit.initializer;
import shit.executor;
import shit.command;

void setDefaultTitle() {
    setConsoleTitle(format("SHIT shell v%s", shitFullVersion));
}

void executeCmdLine(ref GlobalConfig config, string home) {
    scope(exit) setDefaultTitle();

    string path = getcwd();
    path = replaceFirst(path, home, "~");
    writef("%s $ ", path);

    // Read command from stdin
    string command = stdin.readln();
    if (command is null || command == "\n")
        return;
		
	command = command[0 .. $ - 1]; // split \n

    setConsoleTitle(command);
	Command cmd;
    try {
        cmd = Command(command);
    } catch (ParseError) {
        log(format("%s: parse error", command));
        return;
    }
    try {
        auto result = executeCommand(config, cmd);
        if (config.showExitCode) log("exit code " ~ result.getExitCode().to!string);
    } catch (ExecuteException e) {
        log(format("%s: command not found", commandName(cmd)));
    } catch (RegisteredCommandNotFoundException e) {
        log(format("%s: registered command not found", commandName(cmd)));
	}
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

    bool isDefault = false;
    try {
        globalConfig = getGlobalConfig();
        startUp(globalConfig);
    } catch (BadGlobalConfigException e) {
        log("startup error(bad global configures): " ~ e.msg);
        isDefault = true;
    } catch (GlobalConfigNotFoundException e) {
        log("warning: global configures not found: " ~ e.msg);
        isDefault = true;
    } catch (StartUpException e) {
        log("startup error(bad configures): " ~ e.msg);
        isDefault = true;
    }

    if (isDefault) {
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