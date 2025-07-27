module shit.helper.user;

import std.stdio;
import std.string;
import std.process : environment;

string getUserName() {
    version (Windows) {
        string user = environment.get("USERNAME", "");
    } else  {
        string user = environment.get("USER", "");
    }
    return user is null ? "user" : user;
}

string getHostName() {
    version (Windows) {
        string host = environment.get("USERDOMAIN", "");
    } else {
        string host = environment.get("HOSTNAME", "");
    }
    return host is null ? "localhost" : host;
}