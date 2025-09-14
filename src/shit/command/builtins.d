module shit.command.builtins;
@safe:
export:

import std.file : chdir, read, FileException;
import std.path;
import std.stdio;
import std.conv;
import std.getopt;
import std.format;
import std.json;
import shit.executor;
import shit.configs.global;
import helper.exit;
import helper.paths;
import helper.logger;

/++ 
 + Built-in cd defination
 + Params:
 +   args = The command arguments
 + Returns: The exit code
 +/
ExecuteResult builtinCd(string[] args)
{
    try
    {
        if (args.length == 2)
        {
            chdir(args[1]);
        }
        else
        {
            log("Usage: cd <directory>");
        }

        return ExecuteResult(0);
    }
    catch (Exception e)
    {
        log(format("cd: %s: No such file or directory: %s", args[1], e.msg));
        return ExecuteResult(1);
    }
}

/++ 
 + Built-in exit defination
 + Params:
 +   args = The command arguments
 + Returns: The exit code
 +/
ExecuteResult builtinExit(string[] args)
{
    try
    {
        if (args.length == 2)
        {
            exit(args[1].to!int);
        }
        else
        {
            exit(0);
        }
    }
    catch (ConvException)
    {
        log("exit: bad exit code");
    }

    return ExecuteResult(0);
}

/++ 
 + Built-in echo defination
 + Params:
 +   args = The command arguments
 + Returns: The exit code
 +/
ExecuteResult builtinEcho(string[] args)
{
    foreach (str; args[1 .. $])
        write(str);
    writeln();

    return ExecuteResult(0);
}

/++ 
 + Built-in reload defination
 + Params:
 +   args = The command arguments
 + Returns: The exit code
 +/
ExecuteResult builtinReload(string[] args)
{
    if (args.length != 1)
        return ExecuteResult(1);

    gconfig.read();
    if (gconfig.hasException)
    {
        log("error when loading global configuration: " ~ gconfig.exception.msg);
        return ExecuteResult(1);
    }

    return ExecuteResult(0);
}

/++ 
 + Built-in config defination
 + Params:
 +   args = The command argumnets
 + Returns: The exit code
 +/
ExecuteResult builtinConfig(string[] args) @trusted
{
    string key, value, cfg;
    try
    {
        auto help = getopt(
            args,
            std.getopt.config.bundling,
            std.getopt.config.required,
            "key|k", "The key of the configures", &key,
            std.getopt.config.required,
            "value|v", "The value of the configures", &value
        );

        if (help.helpWanted)
        {
            defaultGetoptPrinter("The SHIT terminal configure tool", help.options);
            return ExecuteResult(0);
        }

        auto file = buildPath(ShitInformation.configPath, cfg ~ ".json");
        auto jValue = readJSON(file);

        jValue[key] = value;
        writeJSON(file, jValue);
        
        return ExecuteResult(0);
    }
    catch (GetOptException e)
    {
        log(e.msg);
        return ExecuteResult(1);
    }
    catch (JSONException e)
    {
        log("invalid configure: " ~ e.msg);
        return ExecuteResult(1);
    }
    catch (FileException e)
    {
        log("no configure found: " ~ cfg);
    }

    return ExecuteResult(1);
}

static this() @trusted
{
    new Registry()
        .register("cd", &builtinCd)
        .register("exit", &builtinExit)
        .register("echo", &builtinEcho)
        .register("reload", &builtinReload)
        .register("config", &builtinConfig);
}
