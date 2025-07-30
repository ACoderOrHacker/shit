module shit.configs.project;

import std.path;
import shit.helper.paths;

string shitFullVersion = "0.1.0";
string shitMajorVersion = "0";
string shitMinorVersion = "1";
string shitPatchVersion = "0";
string shitPlatform = "linux";
string shitArchitecture = "x86_64";
string shitOs = "linux";
string shitMode = "release";

string shitConfigsPath() {
    return buildPath(dirName(dirName(executablePath())), "etc", "shit");
}