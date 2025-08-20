module helper.user;

import std.stdio;
import std.string;
import std.process : environment;

string getUserName() @trusted
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

string getHostName() @trusted
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
        import core.sys.windows.windows;

        // see https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-checktokenmembership

        BOOL b;
        SID_IDENTIFIER_AUTHORITY NtAuthority = SECURITY_NT_AUTHORITY;
        PSID AdministratorsGroup;
        b = AllocateAndInitializeSid(
            &NtAuthority,
            2,
            SECURITY_BUILTIN_DOMAIN_RID,
            DOMAIN_ALIAS_RID_ADMINS,
            0, 0, 0, 0, 0, 0,
            &AdministratorsGroup);

        if (b)
        {
            if (!CheckTokenMembership(null, AdministratorsGroup, &b))
            {
                b = FALSE;
            }
            FreeSid(AdministratorsGroup);
        }

        return cast(bool) b;
    }
    else version (Posix)
    {
        import core.sys.posix.unistd : geteuid;

        return geteuid() == 0;
    }
}
