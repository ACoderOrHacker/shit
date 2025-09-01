/+
 [shit.configs.project] is a project configuration for getting
  versions, etc.
 
 + Authors: AcoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/

module shit.configs.project;
@safe:
export:

import std.path;
import helper.paths;
import config;

class ShitInformation
{
    enum fullVersion = shitFullVersion;

    @property
    static string configPath()
    {
        return buildPath(dirName(dirName(executablePath())), "etc", "shit");
    }
}