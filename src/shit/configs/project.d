module shit.configs.project;

import std.path;
import helper.paths;
import config;

export class ShitInformation
{
    enum fullVersion = shitFullVersion;

    @property
    static string configPath()
    {
        return buildPath(dirName(dirName(executablePath())), "etc", "shit");
    }
}