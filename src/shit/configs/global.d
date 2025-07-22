module shit.configs.global;

import std.json;
import std.file;
import std.path;
import std.conv : to;
import shit.configs.project;
import shit.helper.paths;

class GlobalConfigNotFoundException : Exception {
    pure nothrow this(string msg) {
        super(msg);
    }
}

class BadGlobalConfigException : Exception {
    pure nothrow this(string msg) {
        super(msg);
    }
}

struct GlobalConfig {
    string defaultPath;
    bool showExitCode;
}

GlobalConfig getGlobalConfig() {
    GlobalConfig config;
    JSONValue value;

    try {
        string jsonString = cast(string) read(buildPath(shitConfigsPath(), "global.json"));
        value = parseJSON(jsonString);
    } catch (Exception e) {
        throw new GlobalConfigNotFoundException("Unable to read global configuration file");
    }

    try {
        JSONValue jDefaultPath = value["defaultPath"];
        if (jDefaultPath.type == JSONType.string) {
            config.defaultPath = jDefaultPath.str;
            if (config.defaultPath == "~") 
                config.defaultPath = getHome();
        } else {
            throw new BadGlobalConfigException("defaultPath is not a string");
        }
    } catch (JSONException e) {
        throw new GlobalConfigNotFoundException("Unable to read defaultPath from global configuration file");
    }

    try {
        JSONValue jShowExitCode = value["showExitCode"];
        if (jShowExitCode.type == JSONType.true_ || jShowExitCode.type == JSONType.false_) {
            config.showExitCode = jShowExitCode.boolean;
        } else {
            throw new BadGlobalConfigException("showExitCode is not a boolean");
        }
    } catch (JSONException e) {
        throw new GlobalConfigNotFoundException("Unable to read showExitCode from global configuration file");
    }

    return config;
}