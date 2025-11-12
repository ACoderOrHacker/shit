module helper.paths;
@safe:
export:

import std.conv;
import std.process : environment;
import std.algorithm;
import std.string;
import std.path : buildPath, dirName;

/++ 
 * Thrown by getHome
 +/
class HomeNotFoundException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

/++ 
 + Get the home path
 + Returns: The home path
 +/
string getHome() @trusted
{
    version (Posix)
    {
        import std.process : environment;

        // POSIX standard defines this environment variable
        return environment.get("HOME", "/home");
    }
    version (Windows)
    {
        import core.sys.windows.shlobj;
        import core.sys.windows.windows;
        import core.stdc.wchar_;

        wchar_t[260] path;
        if (SHGetFolderPathW(null, CSIDL_PROFILE, null, 0, path.ptr) == 0)
        {
            return path[0 .. wcslen(path.ptr)].to!string;
        }
        throw new HomeNotFoundException("Home directory not found");
    }
}

/++ 
 + Checks if the path is a web url path
 + Params:
 +   path = The url path
 + Returns: If it's a web url path, returns true, or returns false
 +/
bool isUrlPath(string path)
{
    string[] urlProtocols = [
        "http://", "https://", "ftp://", "file://",
        "ws://", "wss://", "mailto:", "tel:"
    ];

    return urlProtocols.any!(protocol => path.startsWith(protocol));
}
