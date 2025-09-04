module shit.initializer;

import std.string;
import std.file : chdir, FileException;
import std.path : buildPath;
import shit.configs.global;
import helper.paths;

export class StartUpException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export void startUp()
{
    try
    {
        string path = gconfig.defaultPath.startsWith("~")
         ? buildPath(getHome(), gconfig.defaultPath[1 .. $]) : gconfig.defaultPath;
        chdir(path);
    }
    catch (FileException e)
    {
        throw new StartUpException("Failed to change default path to: " ~ e.msg);
    }
}
