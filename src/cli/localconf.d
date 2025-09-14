/++
 + Local configurations loading utilities for cli

 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module cli.localconf;
@safe:
export:

import std.stdio;
import std.file;
import std.path;
import helper.logger;
import helper.str;
import shit.configs.global;
import pkgman.configs;
import cli.config;

void checkLocalConfig(in YNResult cliOpt) @trusted
{
    string localPath = buildPath(getcwd(), ".shit");
    YNResult yesOrNo = cliOpt;
    bool isCliInvalid = cliOpt == YNResult.Invalid;
    char readedChar;

    if (yesOrNo == YNResult.Invalid && exists(localPath))
    {
        write("found local configuration, load it? (Y/N) ");
        stdout.flush();
        readf!"%c"(readedChar);
        yesOrNo = checkYesOrNo(readedChar);
        writeln();
    }

    final switch (yesOrNo)
    {
    case YNResult.Yes:
        gconfig.read(localPath);
        pkgconfig.read(localPath);
        checkAndInit();
        if (!gconfig.hasException && !pkgconfig.hasException)
            log("successfully read configurations");
        break;
    case YNResult.No:
        log("canceled to read");
        break;
    case YNResult.Invalid:
        if (!isCliInvalid)
            log("invalid paramter `" ~ readedChar ~ "`");
        break;
    }
    writeln();
}
