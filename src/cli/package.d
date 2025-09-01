module cli;

import std.file : exists, read, getcwd, FileException;
import std.path : buildPath;
import std.stdio : stdout, stderr, writeln, writefln;
import std.format : format;
import std.conv : to, ConvException;
import std.algorithm : startsWith, endsWith, find, filter;
import std.array;
import std.ascii : isControl;
import std.utf;
import std.getopt;
import std.range;
import termcolor;
import cli.logo;
import helper;
import helper.signal;
import shit.configs;
import shit.initializer;
import shit.executor;
import shit.command;
import shit.readline;
import pkgman.basic;
import pkgman.configs;

export void outputInformation()
{
    writefln("SHIT shell v%s, a powerful and modern terminal", ShitInformation.fullVersion);
    writeln("Copyright (C) 2025, ACoderOrHacker");
    writeln();
}

export void setDefaultTitle()
{
    setConsoleTitle(format("SHIT shell v%s", ShitInformation.fullVersion));
}

export void cliExecute(string command, bool showExitcode = true)
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
        auto result = executeCommand(cmd);
        if (gconfig.showExitCode && showExitcode)
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

export void executeCmdLine()
{
    scope (exit)
        setDefaultTitle();

    gconfig.prompts()();

    // Read command from stdin
    string command = new DefaultReadline().read().toUTF8;

    stderr.writeln(); // \n is ignored so we must add it

    if (command.length == 0)
        return; // nothing to do

    setConsoleTitle(command);
    cliExecute(command);
}

export int replMain(bool loadingPackage)
{

    outputInformation();
    setDefaultTitle();

    // Run runners
    PkgmanConfig pkgconfig = getPkgmanConfig();
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

            runners[pkgtype].run(pkg, path);
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

            runners[pkgtype].destroy(pkg, path);
        }
    }

    if (loadingPackage)
    {
        try
        {
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
    }

    try
    {
        while (true)
        {
            executeCmdLine();
            writeln();
        }
    }
    catch (ExitSignal e)
    {
        if (loadingPackage)
            destroyAll();
        return e.getCode(); // exit
    }

    if (loadingPackage)
        destroyAll();
    return 0;
}

export void initWithGlobalConfig()
{
    try
    {
        startUp(gconfig);
    }
    catch (StartUpException e)
    {
        log("startup error(bad configures): " ~ e.msg);
    }
}

export PkgmanConfig getPkgmanConfig()
{
    PkgmanConfig config;
    try
    {
        config = readPkgmanConfig();
    }
    catch (BadPkgmanConfigException e)
    {
        log("bad package configure: " ~ e.msg);
    }
    catch (PkgmanConfigNotFoundException e)
    {
        log("pkgman configure not found: " ~ e.msg);
    }
    return config;
}

export int cliDMain(string[] args)
{
    initSignals();

    if (gconfig.exception !is null)
    {
        log("error when loading global configuration: " ~ gconfig.exception.msg);
        writeln();
    }
    initWithGlobalConfig();

    try
    {
        if (args.length == 1)
        {
            return replMain(true);
        }

        string defaultPackageType = "";
        bool loadingPackage = true;

        void versionHandler(string option)
        {
            outputInformation();

            outputLogo();

            static void linkline(string emoji, string title, string link)
            {
                stdout.write("\t" ~ emoji ~ " ");
                stdout.setColor(Colors.bold)
                    .write(title);
                stdout.setColor(Colors.reset);

                stdout.write(": ");
                stdout.setColor(Colors.underline)
                    .write(link);
                stdout.setColor(Colors.reset);
                writeln();
            }

            linkline("\U0001F449", "Documentations",
                "https://ACoderOrHacker.github.io/shit");

            linkline("\U0001F4AA", "Oh-my-shit",
                "https://github.com/ACoderOrHacker/oh-my-shit");

            writeln();
            writeln();
            
        }

        void replHandler(string option)
        {
            exit(replMain(loadingPackage));
        }

        void executeHandler(string option, string command)
        {
            cliExecute(command, false);
        }

        void installHandler(string option, string file)
        {
            outputInformation();

            shared(Package) pkg = new shared Package(file);
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

            shared(Package) pkg = new shared Package(file);
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

        void disableHandler(string option, string pkgname)
        {
            PkgmanConfig config = getPkgmanConfig();

            if (config.enablePackages.length == 0 || config.enablePackages.find(pkgname).empty)
            {
                log("warning: `" ~ pkgname ~ "` is not in `enabled-packages`");
            }

            auto writedEnabledPackages = config.enablePackages.filter!(s => s != pkgname).array;
            PkgmanConfig writedConfig;
            writedConfig.enablePackages = writedEnabledPackages;

            writePkgmanConfig(writedConfig);

            log("package `" ~ pkgname ~ "` has disabled successfully");
        }

        void enableHandler(string option, string pkgname)
        {
            PkgmanConfig config = getPkgmanConfig();

            if (!config.enablePackages.find(pkgname).empty)
            {
                log("`" ~ pkgname ~ "` is already in `enabled-packages`");
                exit(1);
            }

            config.enablePackages ~= pkgname;

            writePkgmanConfig(config);

            log("package `" ~ pkgname ~ "` has enabled successfully");
        }

        void createPackageHandler(string option, string optfile)
        {
            outputInformation();

            if (defaultPackageType == "")
            {
                new shared Package(optfile).writeDefaultPackage();
                log("warning: you created a empty package");
                log("package `" ~ optfile ~ "` has created successfully.");
            }

            auto packages = getPackages();
            if (defaultPackageType !in packages)
            {
                log("unregistered package `" ~ defaultPackageType ~ "`");
                log("registered packages: ");
                foreach (shared(Package) pkg; packages)
                {
                    log("  " ~ pkg.packageType);
                }
                exit(1);
            }

            shared(Package) pkg = packages[defaultPackageType];
            pkg.setFile(optfile);

            pkg.writeDefaultPackage();

            log("package `" ~ optfile ~ "` has created successfully");
        }

        auto helpInformation = getopt(
            args,
            std.getopt.config.bundling,

            "type|t", "the type to create default package", &defaultPackageType,
            "loading-packages", &loadingPackage,

            "version", "get version", &versionHandler,
            "repl|r", "run repl shell", &replHandler,
            "execute|e", "execute a command", &executeHandler,
            "install|i", "install a package", &installHandler,
            "uninstall|u", "uninstall a package", &uninstallHandler,
            "disable", "disable a installed package", &disableHandler,
            "enable", "enable a installed package", &enableHandler,
            "create|c", "create a default package", &createPackageHandler,
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
    catch (GetOptException e)
    {
        log("command line error: " ~ e.msg);
        return 1;
    }
    catch (ConvException e)
    {
        log(e.msg);
    }
    catch (Exception e)
    {
        internalError(e.msg);
        return 1;
    }

    return 0;
}

extern (C) export int cliCMain(int argc, const(char) **argv)
{
    return cliDMain(convertToStringArray(argv, argc));
}