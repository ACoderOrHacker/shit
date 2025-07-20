module shit.configs.startup;

import std.json;
import std.file;
import std.path;
import shit.configs.project;
import shit.helper.paths;

class StartUpConfigNotFoundException : Exception {
    pure nothrow this(string msg) {
        super(msg);
    }
}

struct StartupConfig {
    string defaultPath;
}

StartupConfig getStartupConfig() {
    StartupConfig config;
    JSONValue value;

    try {
        string jsonString = cast(string) read(buildPath(shitConfigsPath(), "startup.json"));
        value = parseJSON(jsonString);
    } catch (Exception e) {
        throw new StartUpConfigNotFoundException("Unable to read startup config file");
    }

    config.defaultPath = value["defaultPath"].str;
    if (config.defaultPath == "~") {
        // root
        config.defaultPath = getHome();
    }

    return config;
}