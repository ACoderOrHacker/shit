module shit.configs.project;

import std.path;
import shit.helper.paths;

string shitFullVersion = "0.1.0";
string shitMajorVersion = "0";
string shitMinorVersion = "1";
string shitPatchVersion = "0";
string shitPlatform = "windows";
string shitArchitecture = "x64";
string shitOs = "windows";
string shitMode = "release";

string shitConfigsPath() {
    return buildPath(dirName(dirName(executablePath())), "etc", "shit");
}