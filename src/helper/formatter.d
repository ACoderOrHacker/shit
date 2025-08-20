module helper.formatter;

import std.stdio : stdout;
import std.regex;
import std.string;
import std.array;
import std.algorithm.iteration;
import termcolor;

alias FormatValueFunc = string delegate(string[]) @trusted;

enum FormatSliceType : ubyte
{
    Text,
    Variable
}

export struct FormatSlice
{
    FormatSliceType type;
    string str;
}

export FormatSlice[] parseFormatString(string input)
{
    FormatSlice[] result;
    size_t i = 0;
    size_t start = 0;
    enum State
    {
        Text,
        Dollar,
        Variable
    }

    State state = State.Text;

    while (i < input.length)
    {
        switch (state)
        {
        case State.Text:
            if (input[i] == '$' && i + 1 < input.length && input[i + 1] == '{')
            {
                // flush previous text
                if (i > start)
                {
                    result ~= FormatSlice(FormatSliceType.Text, input[start .. i]);
                }
                i += 2;
                start = i;
                state = State.Variable;
            }
            else
            {
                i++;
            }
            break;
        case State.Variable:
            size_t varStart = i;
            while (i < input.length && input[i] != '}')
            {
                i++;
            }
            if (i < input.length && input[i] == '}')
            {
                result ~= FormatSlice(FormatSliceType.Variable, input[varStart .. i]);
                i++; // skip '}'
                start = i;
                state = State.Text;
            }
            else
            {
                // Unclosed variable, treat as text
                result ~= FormatSlice(FormatSliceType.Text, "${" ~ input[varStart .. $]);
                i = input.length;
            }
            break;
        default:
            assert(false); // unreachable
        }
    }
    // Flush remaining text
    if (start < input.length)
    {
        result ~= FormatSlice(FormatSliceType.Text, input[start .. $]);
    }
    return result;
}

export synchronized class Formatter
{

    private static FormatValueFunc[string] values_;

    @property
    static ref FormatValueFunc[string] formatValues()
    {
        return values_;
    }

    static string format(string formatString)
    {
        FormatSlice[] slices = parseFormatString(formatString);
        string result;
        foreach (slice; slices)
        {
            if (slice.type == FormatSliceType.Variable && slice.str.length != 0)
            {
                string[] variableAndParams = slice.str.split(';');
                if (variableAndParams[0] in formatValues)
                    result ~= formatValues[variableAndParams[0]](variableAndParams.length == 1 ? [
                        ] : variableAndParams[1 .. $]);
                continue;
            }
            result ~= slice.str;
        }

        return result;
    }

    static void writef(string formatString)
    {
        FormatSlice[] slices = parseFormatString(formatString);
        foreach (slice; slices)
        {
            if (slice.type == FormatSliceType.Variable && slice.str.length != 0)
            {
                string[] variableAndParams = slice.str.split(';');
                if (variableAndParams[0] in formatValues)
                    stdout.write(formatValues[variableAndParams[0]](variableAndParams.length == 1 ? [
                            ] : variableAndParams[1 .. $]));
                continue;
            }
            stdout.write(slice.str);
        }
    }
}

private string home(string[]) @trusted
{
    import helper.paths;
    import std.path;

    string home_ = getHome();
    if (home_.endsWith(dirSeparator))
    {
        home_ = home_[0 .. $ - dirSeparator.length]; // split dir separator
    }
    return home_;
}

private string tildeCwd(string[]) @trusted
{
    import std.file;

    string path = getcwd();
    return replaceFirst(path, home([]), "~");
}

private string gitBranch(string[]) @trusted
{
    import std.file;
    import helper.git;

    string gitBranch;
    try
    {
        gitBranch = new GitData("git", getcwd(), true).currentBranch;
    }
    catch (GitRepoNotFoundException)
    {
        gitBranch = null;
    }

    return gitBranch == null ? "" : gitBranch;
}

private string admin(string[]) @trusted
{
    import helper.user;

    return isAdmin() ? "#" : "$";
}

static this()
{
    import std.functional;
    import std.conv;
    import std.stdint;
    import helper.user;

    foreach (s; __traits(allMembers, Colors))
    {
        Formatter.formatValues[s] = (string[]) @trusted {
            stdout.setColor(mixin("Colors." ~ s));
            return "";
        };
    }

    string rgbPrint(T)(string[] args) @trusted
    {
        if (args.length != 3)
        {
            return "bad rgb value: argument length is not 3";
        }

        try
        {
            stdout.setColor(T(
                    args[0].to!uint8_t,
                    args[1].to!uint8_t,
                    args[2].to!uint8_t
            ));
            return "";
        }
        catch (ConvException e)
        {
            return e.msg;
        }
    }

    Formatter.formatValues["rgb_foreground"] = &rgbPrint!RGBColor;
    Formatter.formatValues["rgb_background"] = &rgbPrint!OnRGBColor;
    Formatter.formatValues["home"] = toDelegate(&home);
    Formatter.formatValues["tilde_cwd"] = toDelegate(&tildeCwd);
    Formatter.formatValues["git_branch"] = toDelegate(
        &gitBranch);
    Formatter.formatValues["user"] = toDelegate(
        (string[]) @trusted => getUserName());
    Formatter.formatValues["host"] = toDelegate(
        (string[]) @trusted => getHostName());
    Formatter.formatValues["admin"] = toDelegate(
        &admin);
}
