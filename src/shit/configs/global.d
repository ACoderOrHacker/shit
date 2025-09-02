module shit.configs.global;

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

export struct GlobalConfig
{
    string defaultPath;
    bool showExitCode;

    @IgnoreItem
    WritePromptsFunc prompts;
    
    private static void defaultPrompts()
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