/++
 + [Config] utilities for cli

 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module cli.config;
@safe:
export:

import std.stdio;
import shit.configs.global;
import pkgman.configs;
import shit.initializer;
import helper;

/++ 
 + Check all configurations and initialize with them
 + If failed, log it on console
 +/
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