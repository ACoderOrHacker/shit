/+
 + A project configuration for getting versions, etc.
 + Authors: AcoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/

module shit.configs.project;
@safe:
export:

import std.file;
import std.path;
import config;

/++ 
 + The shit basic information
 +/
class ShitInformation
{
    enum fullVersion = shitFullVersion;

    /++ 
     + Get the global configuration directory
     + Returns: The directory
     +/
    @property
    static string configPath()
    {
        return buildPath(dirName(dirName(thisExePath)), "etc", "shit");
    }
}