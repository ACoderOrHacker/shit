module cli;

import std.file;
import std.path;
import std.stdio;
import std.format : format;
import std.conv : to;
import std.algorithm : startsWith, endsWith;
import std.ascii : isControl;
import std.utf;
import std.getopt;
import termcolor;
import helper;
import helper.signal;
import shit.configs;
import shit.initializer;
import shit.executor;
import shit.command;
import shit.readline;
import pkgman.basic;
import pkgman.configs;

void outputInformation()
{
    // output information
    writefln("SHIT shell v%s, a powerful and modern terminal", shitFullVersion);
    writefln("On [%s, %s], on %s mode",
        shitOs, shitArchitecture, shitMode);
    writeln("Copyright (C) 2025, ACoderOrHacker");
    writeln();
}

export void setDefaultTitle()
{
    setConsoleTitle(format("SHIT shell v%s", shitFullVersion));
}

export void cliExecute(ref GlobalConfig config, string command, bool showExitcode = true)
{
    Command cmd = Command("");
    try
    {
        cmd = Command(command);
    }
    catch (ParseError)
    {
        log(format("%s: parse error", command));
        return;
    }

    try
    {
        auto result = executeCommand(config, cmd);
        if (config.showExitCode && showExitcode)
            log("exit code " ~ result.getExitCode().to!string);
    }
    catch (ExecuteException e)
    {
        log(e.msg);
    }
    catch (RegisteredCommandNotFoundException e)
    {
        log(format("%s: registered command not found", commandName(cmd)));
    }
}

export void executeCmdLine(GlobalConfig config)
{
    scope (exit)
        setDefaultTitle();

    config.prompts();

    // Read command from stdin
    string command = new DefaultReadline().read().toUTF8;

    stderr.writeln(); // \n is ignored so we must add it

    if (command.length == 0)
        return; // nothing to do

    setConsoleTitle(command);
    cliExecute(config, command);
}

export int replMain()
{

    outputInformation();
    GlobalConfig globalConfig = initWithGlobalConfig();
    setDefaultTitle();

    // Run runners
    PkgmanConfig pkgconfig;
    shared(Runners) runners;

    void runAll()
    {
        foreach (i, pkg; pkgconfig.enablePackages)
        {
            string path = buildPath(packagesPath, pkg);
            string pkgtypePath = buildPath(path, ".pkgtype");

            if (!exists(pkgtypePath))
            {
                log("bad pkgtype `" ~ pkgtypePath ~ "`");
                break;
            }
            string pkgtype = cast(string) read(pkgtypePath);

            if (pkgtype !in runners)
            {
                log("unsupported package type: " ~ pkgtype);
                break;
            }

            runners[pkgtype].run(pkg, path, globalConfig);
        }
    }

    void destroyAll()
    {
        foreach (i, pkg; pkgconfig.enablePackages)
        {
            string path = buildPath(packagesPath, pkg);
            string pkgtypePath = buildPath(path, ".pkgtype");

            if (!exists(pkgtypePath))
            {
                log("bad pkgtype `" ~ pkgtypePath ~ "`");
                break;
            }
            string pkgtype = cast(string) read(pkgtypePath);

            if (pkgtype !in runners)
            {
                log("unsupported package type: " ~ pkgtype);
                break;
            }

            runners[pkgtype].destroy(pkg, path, globalConfig);
        }
    }

    try
    {
        pkgconfig = readPkgmanConfig();
        runners = getRunners();

        runAll();
    }
    catch (ExtensionRunException e)
    {
        log("error when running extensions...");
        log("  details: " ~ e.msg);
    }
    catch (BadPkgmanConfigException e)
    {
        log("bad package configure: " ~ e.msg);
    }
    catch (PkgmanConfigNotFoundException e)
    {
        log("pkgman configure not found: " ~ e.msg);
    }
    catch (FileException e)
    {
        log("bad read for .pkgtype: " ~ e.msg);
    }

    try
    {
        while (true)
        {
            executeCmdLine(globalConfig);
            writeln();
        }
    }
    catch (ExitSignal e)
    {
        destroyAll();
        return e.getCode(); // exit
    }

    destroyAll();
    return 0;
}

export GlobalConfig initWithGlobalConfig()
{
    GlobalConfig globalConfig;

    bool isDefault = false;
    try
    {
        globalConfig = getGlobalConfig();
        startUp(globalConfig);
    }
    catch (BadGlobalConfigException e)
    {
        log("startup error(bad global configures): " ~ e.msg);
        isDefault = true;
    }
    catch (GlobalConfigNotFoundException e)
    {
        log("warning: global configures not found: " ~ e.msg);
        isDefault = true;
    }
    catch (StartUpException e)
    {
        log("startup error(bad configures): " ~ e.msg);
        isDefault = true;
    }

    if (isDefault)
    {
        globalConfig.showExitCode = false;
        globalConfig.defaultPath = getHome();
        try
        {
            startUp(globalConfig);
        }
        catch (StartUpException e)
        {
            // that is the default configuration,
            // if it fails, then maybe the getHome or anyelse gets bad works
            internalError(e.msg);
            exit(1);
        }
    }
    globalConfig.prompts = delegate() { write(getcwd(), " $ "); };

    return globalConfig;
}

extern (C) export int cliMain(int argc, const(char)** argv)
{
    initSignals();

    try
    {
        string[] args = convertToStringArray(argv, argc);

        if (args.length == 1)
        {
            return replMain();
        }

        string defaultPackageType;

        void replHandler(string option)
        {
            exit(replMain());
        }

        void executeHandler(string option, string command)
        {
            GlobalConfig config = initWithGlobalConfig();
            cliExecute(config, command, false);
        }

        void installHandler(string option, string file)
        {
            outputInformation();

            Package pkg = new Package(file);
            try
            {
                pkg.install();

                log("package `" ~ file ~ "` has installed successfully");
            }
            catch (Exception e)
            {
                log("error when installing package `" ~ file ~ "`: " ~ e.msg);
                exit(1);
            }
        }

        void uninstallHandler(string option, string file)
        {
            outputInformation();

            Package pkg = new Package(file);
            try
            {
                pkg.uninstall();

                log("package `" ~ file ~ "` has uninstalled successfully");
            }
            catch (Exception e)
            {
                log("error when uninstalling package `" ~ file ~ "`: " ~ e.msg);
                exit(1);
            }
        }

        void createPackageHandler(string option, string optfile)
        {
            outputInformation();

            Package pkg = new Package(optfile);

            pkg.writeDefaultPackage(defaultPackageType);

            log("package `" ~ optfile ~ "` has created successfully");
        }

        auto helpInformation = getopt(
            args,
            "repl|r", "run repl shell", &replHandler,
            "execute|e", "execute a command", &executeHandler,
            "install|i", "install a package", &installHandler,
            "uninstall|u", "uninstall a package", &uninstallHandler,
            "create|c", "create a default package", &createPackageHandler,
            "type|t", "the type to create default package", &defaultPackageType
        );

        if (helpInformation.helpWanted)
        {
            defaultGetoptPrinter("The SHIT terminal", helpInformation.options);
            return 0;
        }
    }
    catch (ExitSignal e)
    {
        return e.getCode();
    }
    catch (Exception e)
    {
        internalError(e.msg);
        return 1;
    }

    return 0;
}
