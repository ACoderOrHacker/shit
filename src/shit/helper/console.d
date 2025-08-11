module shit.helper.console;

import std.stdio;
import std.exception;
import std.conv : to;
import std.utf;
import std.format;

version (Posix) {
    import core.sys.posix.termios;
    import core.sys.posix.unistd;
} else version (Windows) {
    import core.sys.windows.windows;

    static assert(false, "TODO: not implemented");
    // TODO: not implemented!!!
} else {
    static assert(false, "Unsupported platform");
}

class ConsoleSettingException : Exception {
    this(string msg) {
        super(msg);
    }
}

class TerminalMode {
private:
    termios original;
    bool isCbreak = false;

    void saveCurrent() {
        if (tcgetattr(STDIN_FILENO, &original) < 0) {
            throw new ConsoleSettingException("Failed to get terminal attributes");
        }
    }

    void applySettings(termios settings) {
        if (tcsetattr(STDIN_FILENO, TCSANOW, &settings) < 0) {
            throw new ConsoleSettingException("Failed to set terminal attributes");
        }
    }

public:
    this() {
        saveCurrent();
    }

    ~this() {
        restore();
    }

    void enableCbreak(ubyte timeout = 0) {
        if (isCbreak) return;

        termios settings = original;
        settings.c_lflag &= ~(ICANON | ECHO);

        settings.c_cc[VMIN] = 1;
        settings.c_cc[VTIME] = timeout;

        applySettings(settings);
        isCbreak = true;
    }

    void restore() {
        if (!isCbreak) return;
        applySettings(original);
        isCbreak = false;
    }
}

// TODO: add windows solution!!!

void backnFromLineStart(File stream, ulong n) {
    stream.write("\r\033[" ~ n.to!string ~ "C");
    stream.flush();
}

void clearFromCursor(File stream) {
    stream.write("\033[K");
}

// Read characters

class ReadCharException : Exception {
    this(string msg) {
        super(msg);
    }
}

private int utf8CharLength(ubyte firstByte) {
    if ((firstByte & 0x80) == 0x00) { // 0xxxxxxx
        return 1;
    } else if ((firstByte & 0xE0) == 0xC0) { // 110xxxxx
        return 2;
    } else if ((firstByte & 0xF0) == 0xE0) { // 1110xxxx
        return 3;
    } else if ((firstByte & 0xF8) == 0xF0) { // 11110xxx
        return 4;
    } else {
        return -1;
    }
}

alias utf8char = string;

bool readChar(ubyte *c) {
    return read(STDIN_FILENO, c, 1) == 1;
}

// TODO: add windiws version
utf8char readUtf8Char() {
    ubyte firstByte;
    if (!readChar(&firstByte)) {
        throw new ReadCharException("failed read a character");
    }

    int charLen = utf8CharLength(firstByte);
    if (charLen < 1) {
        throw new ReadCharException(format("invalid utf-8 character code: 0x%02X", firstByte));
    }

    ubyte[4] buffer;
    buffer[0] = firstByte;
    int bytesRead = 1;

    while (bytesRead < charLen) {
        if (!readChar(&buffer[bytesRead])) {
            throw new ReadCharException("failed read the utf-8 character");
        }

        if ((buffer[bytesRead] & 0xC0) != 0x80) {
            throw new ReadCharException(format("invalid utf-8 character: 0x%02X", buffer[bytesRead]));
        }

        bytesRead++;
    }

    string utf8Char = cast(string) buffer[0..charLen].idup;
    std.utf.validate(utf8Char);

    return utf8Char;
}