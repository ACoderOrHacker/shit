module cli.localconf;
@safe:

import std.stdio;
import std.file;
import std.path;
import helper.logger;
import helper.str;
import shit.configs.global;
import cli.config;

void checkLocalConfig(YNResult cliOpt) @trusted
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
        checkAndInit();
        if (!gconfig.hasException)
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
