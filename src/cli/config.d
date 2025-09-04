module cli.config;

import std.stdio;
import shit.configs.global;
import shit.initializer;
import helper;

void checkAndInit()
{
    if (gconfig.hasException)
    {
        log("error when loading configurations: "
            ~ gconfig.exception.msg);
    }

    try
    {
        startUp();
    }
    catch(StartUpException e)
    {
        log("startup error: " ~ e.msg);
    }
}