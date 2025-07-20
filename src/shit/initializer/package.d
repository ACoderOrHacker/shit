module shit.initializer;

import std.file : chdir;
import shit.configs.startup;

class StartUpException : Exception {
    this(string msg) {
        super(msg);
    }
}

void startUp() {
    try {
        StartupConfig config = getStartupConfig();

        chdir(config.defaultPath);
    } catch (Exception e) {
        throw new StartUpException("Failed to load startup config: " ~ e.msg);
    }
}