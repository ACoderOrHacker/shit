module shit.command.parser;

import std.stdio;
import std.string;
import std.exception;
import std.array;

enum State {
    Delimiter,
    Unquoted,
    SingleQuoted,
    DoubleQuoted,
    Backslash,
    UnquotedBackslash,
    DoubleQuotedBackslash,
    Comment,
}

class ParseError : Exception {
    @safe
    this(string msg = "Parse error") {
        super(msg);
    }
}

@safe
string[] splitCommand(string s) {
    State state = State.Delimiter;
    string[] words;
    auto word = appender!string();
    auto chars = s.representation;
    size_t i = 0;

    while (true) {
        char c = i < chars.length ? cast(char)chars[i] : 0;
        bool isEnd = i >= chars.length;

        final switch (state) {
            case State.Delimiter:
                if (isEnd) goto done;
                else if (c == '\'') state = State.SingleQuoted;
                else if (c == '"') state = State.DoubleQuoted;
                else if (c == '\\') state = State.Backslash;
                else if (c == '\t' || c == ' ' || c == '\n') state = State.Delimiter;
                else if (c == '#') state = State.Comment;
                else {
                    word.put(c);
                    state = State.Unquoted;
                }
                break;

            case State.Backslash:
                if (isEnd) {
                    word.put('\\');
                    words ~= word.data;
                    word = appender!string();
                    goto done;
                } else if (c == '\n') state = State.Delimiter;
                else {
                    word.put(c);
                    state = State.Unquoted;
                }
                break;

            case State.Unquoted:
                if (isEnd) {
                    words ~= word.data;
                    word = appender!string();
                    goto done;
                } else if (c == '\'') state = State.SingleQuoted;
                else if (c == '"') state = State.DoubleQuoted;
                else if (c == '\\') state = State.UnquotedBackslash;
                else if (c == '\t' || c == ' ' || c == '\n') {
                    words ~= word.data;
                    word = appender!string();
                    state = State.Delimiter;
                } else {
                    word.put(c);
                    state = State.Unquoted;
                }
                break;

            case State.UnquotedBackslash:
                if (isEnd) {
                    word.put('\\');
                    words ~= word.data;
                    word = appender!string();
                    goto done;
                } else if (c == '\n') state = State.Unquoted;
                else {
                    word.put(c);
                    state = State.Unquoted;
                }
                break;

            case State.SingleQuoted:
                if (isEnd) throw new ParseError();
                else if (c == '\'') state = State.Unquoted;
                else {
                    word.put(c);
                    state = State.SingleQuoted;
                }
                break;

            case State.DoubleQuoted:
                if (isEnd) throw new ParseError();
                else if (c == '"') state = State.Unquoted;
                else if (c == '\\') state = State.DoubleQuotedBackslash;
                else {
                    word.put(c);
                    state = State.DoubleQuoted;
                }
                break;

            case State.DoubleQuotedBackslash:
                if (isEnd) throw new ParseError();
                else if (c == '\n') state = State.DoubleQuoted;
                else if (c == '$' || c == '`' || c == '"' || c == '\\') {
                    word.put(c);
                    state = State.DoubleQuoted;
                } else {
                    word.put('\\');
                    word.put(c);
                    state = State.DoubleQuoted;
                }
                break;

            case State.Comment:
                if (isEnd) goto done;
                else if (c == '\n') state = State.Delimiter;
                else state = State.Comment;
                break;
        }

        ++i;
    }

done:
    return words;
}