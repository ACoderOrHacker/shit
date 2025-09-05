module cli.config;

import std.stdio;
import shit.configs.global;
import pkgman.configs;
import shit.initializer;
import helper;

void checkAndInit()
{
    if (gconfig.hasException)
    {
        log("error when loading global configurations: "
            ~ gconfig.exception.msg);
    }

    if (pkgconfig.hasException)
    {
        log("error when loading pkgman configurations: "
            ~ pkgconfig.exception.msg);
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