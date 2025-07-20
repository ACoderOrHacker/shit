module shit.helper.paths;

import std.conv;

class ExecutableNotFoundError : Exception {
    pure nothrow this(string msg) {
        super(msg);
    }
}

class HomeNotFoundError : Exception {
    pure nothrow this(string msg) {
        super(msg);
    }
}

version (Posix) {
    import std.path;
    import core.sys.posix.unistd;

    nothrow
    string getHome() {
        return expandTilde("~");
    }

    string executablePath() {
        char[1024] buffer;
        ssize_t len = readlink("/proc/self/exe", buffer.ptr, buffer.sizeof);
        if (len == -1) throw new ExecutableNotFoundError("Executable not found");
        return buffer[0..len].to!string;
    }
}

version (Windows) {
    import core.sys.windows.shlobj : SHGetFolderPathW, CSIDL_PROFILE;
    import core.sys.windows.windows;
    import core.stdc.wchar_ : wchar_t, wcslen;
    
    string getHome() {
        wchar_t[260] path;
        if (SHGetFolderPathW(null, CSIDL_PROFILE, null, 0, path.ptr) == 0) {
            return path[0 .. wcslen(path.ptr)].to!string;
        }
        throw new HomeNotFoundError("Home directory not found");
    }

    string executablePath() {
        wchar_t[1024] buffer;
        auto len = GetModuleFileNameW(null, buffer.ptr, buffer.sizeof);
        if (len == 0) throw new ExecutableNotFoundError("Executable not found");
        return buffer[0..len].to!string;
    }
}