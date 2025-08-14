module shit.command.finder;

import std.file;
import std.path;
import std.algorithm;
import std.string;
import std.process : environment;

version (Windows)
{
    import core.sys.windows.windows;
}
else version (Posix)
{
    import core.sys.posix.unistd;
}
else
{
    static assert(false, "Unsupported platform");
}

// TODO: add App Path for windows

private bool isExecutable(string path)
{
    if (!exists(path) || !isFile(path))
        return false;

    version (Windows)
    {
        string ext = std.path.extension(path).toLower();
        string[] validExts = split(environment.get("PATHEXT", ".EXE;.CMD;.BAT;.COM"), ";");
        return validExts.canFind(ext.toUpper);
    }
    else
    {
        return access(path.toStringz(), X_OK) == 0;
    }
}

export string findProgram(string programName)
{
    // absolute path
    if (programName.canFind('\\') || programName.canFind('/'))
    {
        return isExecutable(programName) ? programName : null;
    }

    // TODO: add App Path there

    // find in current directory
    string currentDir = buildPath(getcwd(), programName);
    if (isExecutable(currentDir))
        return currentDir;

    // find in PATH
    string pathEnv = environment.get("PATH", "");
    if (pathEnv.empty)
        return null;

    version (Windows)
    {
        char spliter = ';';
    }
    else
    {
        char spliter = ':';
    }

    foreach (dir; split(pathEnv, spliter))
    {
        if (dir.empty)
            continue;
        string fullPath = buildPath(dir, programName);

        version (Windows)
        {
            if (!fullPath.endsWith(".exe"))
            {
                string exePath = fullPath ~ ".exe";
                if (isExecutable(exePath))
                    return exePath;
            }
        }

        if (isExecutable(fullPath))
            return fullPath;
    }

    return null;
}
