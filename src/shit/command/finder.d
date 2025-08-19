module shit.command.finder;

import std.file;
import std.path;
import std.algorithm;
import std.string;
import std.process : environment;

version (Windows)
{
    import core.sys.windows.windows;
    import core.sys.windows.winreg;
}
else version (Posix)
{
    import core.sys.posix.unistd;
}
else
{
    static assert(false, "Unsupported platform");
}

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
        return access(toStringz(path), X_OK) == 0;
    }
}

version (Windows) private string findFromAppPath(string programName)
{
    string regName = baseName(programName);
    if (!regName.endsWith(".exe"))
    {
        regName ~= ".exe";
    }
    HKEY hKey = null;
    DWORD dwType = REG_SZ;

    LONG lRet = RegOpenKeyExA(HKEY_LOCAL_MACHINE, toStringz(
            "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\" ~ regName), 0, KEY_QUERY_VALUE, &hKey);

    if (lRet != ERROR_SUCCESS)
        return null;

    DWORD dataSize;
    LONG lStatus = RegGetValueA(hKey, null, null, RRF_RT_REG_SZ, null, null, &dataSize);

    if (lStatus != ERROR_SUCCESS)
        return null;

    // create a buffer
    char[] buffer;
    buffer.length = dataSize;

    lStatus = RegGetValueA(hKey, null, null, RRF_RT_REG_SZ, null, cast(PVOID) buffer.ptr, &dataSize);

    if (lStatus != ERROR_SUCCESS)
        return null;

    return cast(string) fromStringz(buffer);
}

export string findProgram(string programName)
{
    // absolute path
    if (programName.canFind('\\') || programName.canFind('/'))
    {
        return isExecutable(programName) ? programName : null;
    }

    version (Windows)
    {
        string appPathResult = findFromAppPath(programName);
        if (appPathResult !is null)
            return appPathResult;
    }

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
