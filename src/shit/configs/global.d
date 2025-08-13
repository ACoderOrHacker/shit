module shit.configs.global;

import std.json;
import std.file;
import std.path;
import std.conv : to;
import shit.configs.project;
import shit.helper.paths;
public import shit.configs.basic;
public import shit.configs.project;

class GlobalConfigNotFoundException : Exception
{
    pure nothrow this(string msg)
    {
        super(msg);
    }
}

class BadGlobalConfigException : Exception
{
    pure nothrow this(string msg)
    {
        super(msg);
    }
}

struct GlobalConfig
{
    string defaultPath;
    bool showExitCode;
    string gitDir;
}

GlobalConfig getGlobalConfig()
{
    GlobalConfig config;
    JSONValue value;

    try
    {
        value = readJSON(buildPath(shitConfigsPath(), "global.json"));
    }
    catch (Exception e)
    {
        throw new GlobalConfigNotFoundException("Unable to read global configuration file");
    }

    try
    {
        JSONValue jDefaultPath = value["defaultPath"];
        if (jDefaultPath.type == JSONType.string)
        {
            config.defaultPath = jDefaultPath.str;
            if (config.defaultPath == "~")
                config.defaultPath = getHome();
        }
        else
        {
            throw new BadGlobalConfigException("defaultPath is not a string");
        }
    }
    catch (JSONException e)
    {
        throw new GlobalConfigNotFoundException(
            "Unable to read defaultPath from global configuration file");
    }

    try
    {
        JSONValue jShowExitCode = value["showExitCode"];
        if (jShowExitCode.type == JSONType.string)
        {
            config.showExitCode = jShowExitCode.str == "true" ? true : false;
        }
        else
        {
            throw new BadGlobalConfigException("showExitCode is not a string");
        }
    }
    catch (JSONException e)
    {
        throw new GlobalConfigNotFoundException(
            "Unable to read showExitCode from global configuration file");
    }

    try
    {
        JSONValue jGitDir = value["git-executable-dir"];
        if (jGitDir.type == JSONType.string)
        {
            config.gitDir = jGitDir.str == "" ? null : jGitDir.str;
        }
        else
        {
            throw new BadGlobalConfigException("git-executable-dir is not a string");
        }
    }
    catch (JSONException e)
    {
        throw new GlobalConfigNotFoundException(
            "Unable to read git-executable-dir from global configuration file");
    }

    return config;
}
