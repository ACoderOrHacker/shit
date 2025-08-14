module shit.initializer;

import std.file : chdir, FileException;
import shit.configs.global : GlobalConfig;

export class StartUpException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export void startUp(ref GlobalConfig config)
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
