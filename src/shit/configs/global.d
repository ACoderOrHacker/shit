/++
 + The global configuration based on JSONConfig
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module shit.configs.global;
@safe:
export:

import std.json;
import std.file;
import std.path;
import std.conv : to;
import std.functional : toDelegate;
import shit.configs.project;
import helper.paths;
import shit.configs.jsonconfigdef;
public import shit.configs.basic;
public import shit.configs.project;

alias WritePromptsFunc = void delegate();

/++ 
 + The global configuration definatiob
 +/
struct GlobalConfig
{
    string defaultPath;
    bool showExitCode;

    @IgnoreItem
    WritePromptsFunc prompts;
    
    private static void defaultPrompts() @trusted
    {
        import std.stdio : stdout;
        import std.file : getcwd;

        stdout.write(getcwd(), " $ ");
        stdout.flush();
    }

    void initialize() @trusted
    {
        defaultPath = getHome();
        showExitCode = false;
        prompts = toDelegate(&defaultPrompts);
    }
}

alias gconfig = JSONConfig!(GlobalConfig, "global.json");
