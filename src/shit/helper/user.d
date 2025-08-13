module shit.helper.user;

import std.stdio;
import std.string;
import std.process : environment;

string getUserName()
{
    version (Windows)
    {
        string user = environment.get("USERNAME", "user");
    }
    else
    {
        string user = environment.get("USER", "user");
    }
    return user;
}

string getHostName()
{
    version (Windows)
    {
        string host = environment.get("USERDOMAIN", "localhost");
    }
    else
    {
        string host = environment.get("HOSTNAME", "localhost");
    }
    return host;
}

bool isAdmin()
{
    version (Windows)
    {
        // TODO: add windows version
    }
    else version (Posix)
    {
        import core.sys.posix.unistd : geteuid;

        return geteuid() == 0;
    }
}
