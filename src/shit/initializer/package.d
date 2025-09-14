module shit.initializer;
@safe:
export:

import std.string;
import std.file : chdir, FileException;
import std.path : buildPath;
import shit.configs.global;
import helper.paths;

class StartUpException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

void startUp()
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
    catch (Exception e)
    {
        throw new StartUpException(e.msg);
    }
}
