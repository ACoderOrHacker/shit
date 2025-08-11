module shit.main;

import std.file;
import std.path;
import std.stdio;
import std.format : format;
import std.conv : to;
import std.algorithm : startsWith, endsWith;
import std.ascii : isControl;
import std.utf;
import colored;
import shit.helper;
import shit.helper.signal;
import shit.configs.project;
import shit.configs.global;
import shit.initializer;
import shit.executor;
import shit.command;
import shit.command.parser;
import shit.readline;
import shit.readline.controlchar;
import shit.readline.events;
import pkgman.basic;

void setDefaultTitle() {
    setConsoleTitle(format("SHIT shell v%s", shitFullVersion));
}

void executeCmdLine(ref GlobalConfig config, string home) {
    scope (exit) setDefaultTitle();

    string path = getcwd();
    string showPath = replaceFirst(path, home, "~");
    string gitBranch;
    try {
        gitBranch = new GitData(config.gitDir, path, true).currentBranch;
    } catch (GitRepoNotFoundException) {
        gitBranch = null;
    }

    (getUserName() ~ "@" ~ getHostName() ~ " ").green.write;
    showPath.lightBlue.write;
    string branchInfo = gitBranch == null ? "" : " (" ~ gitBranch ~ ")";
    branchInfo.yellow.writeln;

    string indicatorOfCommand = isAdmin() ? "# " : "$ ";
    stderr.write(indicatorOfCommand);
    stderr.flush();

    // Set console to cbreak mode
    auto term = new TerminalMode();
    term.enableCbreak();

    scope(failure) term.restore();

    ulong commandLong = 0; // writed command string length (bytes)
    ulong beforeCursorCommandBytes = 0;

    typingCommandProcessType typingCommand = delegate(File, string command) {
        string color;
        try {
            Command cmd = Command(command);
            color = isValidCommand(cmd) ? "\033[32m" : "\033[31m";
        } catch (ParseError) {
            color = "\033[37m";
        }

        backnFromLineStart(stderr, indicatorOfCommand.length);
        clearFromCursor(stderr);
        stderr.write(color, command, "\033[0m");
        backnFromLineStart(stderr, indicatorOfCommand.length + beforeCursorCommandBytes);
        stderr.flush();

        commandLong = command.length;
    };

    // Read command from stdin
    string command = readline(stdin, "\n",
        new ReadlineConfig()
            .setInsertChar(
                delegate(ref string s, utf8char c) {
                    string beforeBytes = s[0 .. beforeCursorCommandBytes];
                    string afterBytes = s[beforeCursorCommandBytes .. $];
                    s = beforeBytes ~ c ~ afterBytes;
                    beforeCursorCommandBytes += c.length;
                }
            ).setTypingCommand(
                typingCommand
            ).setControlChar(
                delegate(File stream, ref string result, char c) {
                    if (c == 127 || c == 8) {
                        // DEL or BS
                        if (commandLong == 0)
                            return false; // cannot delete characters
                        utf8char deleteChar = utf8RangeBeforeWithCombining(result, beforeCursorCommandBytes);
                        foreach (char _; deleteChar)
                            stderr.write("\b \b");
                        stderr.flush();

                        string before = result[0 .. beforeCursorCommandBytes - deleteChar.length];
                        string after = result[beforeCursorCommandBytes .. $];

                        result = before ~ after;
                        commandLong = result.length;
                        beforeCursorCommandBytes -= deleteChar.length;
                        typingCommand(stream, result);
                    } else if (c == 27) {
                        // ESCAPE
                        string code = readEscapeSequence();
                        Event ev = processEscapeSequence(code);

                        ev.match!(
                            delegate(CursorMoveEvent e) {
                                if (beforeCursorCommandBytes == 0) return;
                                if (e.direction == CursorMoveType.Left) {
                                    stderr.write("\x1b[" ~ e.step.to!string ~ "D");
                                    beforeCursorCommandBytes -= utf8RangeBeforeWithCombining(result, beforeCursorCommandBytes).length;
                                } else if (e.direction == CursorMoveType.Right) {
                                    stderr.write("\x1b[" ~ e.step.to!string ~ "C");
                                    beforeCursorCommandBytes += stride(result[beforeCursorCommandBytes .. $], 0);
                                }
                            },
                            _ => stderr.write(code)
                        );
                    }

                    return false;
                }
            ));

    term.restore();

    stderr.writeln(); // \n is ignored so we must add it

    if (command.length == 0)
        return; // nothing to do

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
        if (config.showExitCode)
            log("exit code " ~ result.getExitCode().to!string);
    } catch (ExecuteException e) {
        log(e.msg);
    } catch (RegisteredCommandNotFoundException e) {
        log(format("%s: registered command not found", commandName(cmd)));
    }
}

int main() {
    initSignals();

    try {
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
        }
        catch (BadGlobalConfigException e) {
            log("startup error(bad global configures): " ~ e.msg);
            isDefault = true;
        }
        catch (GlobalConfigNotFoundException e) {
            log("warning: global configures not found: " ~ e.msg);
            isDefault = true;
        }
        catch (StartUpException e) {
            log("startup error(bad configures): " ~ e.msg);
            isDefault = true;
        }

        if (isDefault) {
            globalConfig.showExitCode = false;
            globalConfig.defaultPath = home;
            try {
                startUp(globalConfig);
            }
            catch (StartUpException e) {
                // that is the default configuration,
                // if it fails, then maybe the getHome or anyelse gets bad works
                internalError(e.msg);
                return 1;
            }
        }

        setDefaultTitle();
        try {
            while (true) {
                executeCmdLine(globalConfig, home);
                writeln();
            }
        } catch (ExitSignal e) {
            return e.getCode(); // exit
        }

    } catch (Exception e) {
        internalError(e.msg);
        return 1;
    }

    return 0;
}
