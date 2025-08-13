module shit.command.builtins;

import std.file : chdir, read, FileException;
import std.path;
import std.stdio;
import std.conv;
import std.getopt;
import std.format;
import std.json;
import shit.executor;
import shit.configs.global;
import shit.helper.exit;
import shit.helper.paths;
import shit.helper.logger;

ExecuteResult builtinCd(ref GlobalConfig config, string[] args)
{
    scope (failure)
    {
        log(format("cd: %s: No such file or directory", args[1]));
        return ExecuteResult(1);
    }
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

ExecuteResult builtinExit(ref GlobalConfig config, string[] args)
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

ExecuteResult builtinEcho(ref GlobalConfig config, string[] args)
{
    foreach (str; args[1 .. $])
        write(str);
    writeln();

    return ExecuteResult(0);
}

ExecuteResult builtinReload(ref GlobalConfig config, string[] args)
{
    if (args.length != 1)
        return ExecuteResult(1);

    string home = getHome();
    try
    {
        config = getGlobalConfig();
    }
    catch (BadGlobalConfigException e)
    {
        log("startup error(bad global configures): " ~ e.msg);
        config.showExitCode = false;
        config.defaultPath = home;
    }
    catch (GlobalConfigNotFoundException e)
    {
        log("global configures not found: " ~ e.msg);
        config.showExitCode = false;
        config.defaultPath = home;
    }

    return ExecuteResult(0);
}

ExecuteResult builtinConfig(ref GlobalConfig config, string[] args)
{
    string key, value, cfg;
    try
    {
        auto help = getopt(
            args,
            std.getopt.config.bundling,
            std.getopt.config.required,
            "config|c", "The configure name (such as `global`)", &cfg,
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

        string path = buildPath(shitConfigsPath(), cfg ~ ".json");
        JSONValue jVal = readJSON(path);

        jVal[key] = value;
        writeJSON(path, jVal, true);
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
    catch (SafeWriteException e)
    {
        log("failed to write configure: " ~ e.msg);
    }

    return ExecuteResult(1);
}

static this()
{
    new Registry()
        .register("cd", &builtinCd)
        .register("exit", &builtinExit)
        .register("echo", &builtinEcho)
        .register("reload", &builtinReload)
        .register("config", &builtinConfig);
}
