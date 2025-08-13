module shit.initializer;

import std.file : chdir, FileException;
import shit.configs.global : GlobalConfig;

class StartUpException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

void startUp(ref GlobalConfig config)
{
    try
    {
        chdir(config.defaultPath);
    }
    catch (FileException e)
    {
        throw new StartUpException("Failed to change default path to: " ~ e.msg);
    }
}
