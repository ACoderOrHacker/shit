/++
 + The formatter of shit, add format variable for formatting
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.formatter;
@safe:
export:

static import stdio = std.stdio;
import std.regex;
import std.string;
import std.array;
import std.algorithm.iteration;
static import format_ = std.format;
import std.traits;
import termcolor;

/++
 + The format value getter function prototype
 +/
alias FormatValueFunc = string delegate(string[]) @trusted;

/++ 
 + The format slice type
 + *Text* means the slice is a normal text (not format variable)
 + *Variable* means the slice is a format variable

 + See_Also: FormatSlice
 +/
private enum FormatSliceType : ubyte
{
    Text,
    Variable
}

/++ 
 * The format slice prototype
 + Includes *type* and *str*
 + *type* is the type of the slice
 + *str* is the details of the slice
 + If type is *Variable*, then just includes the variable name

 + See_Also: FormatSliceType
 +/
private struct FormatSlice
{
    FormatSliceType type;
    string str;
}

/++ 
 + Parse a input string to slices
 + Params:
 +   input = the input full string
 + Returns: Slices of the input
 + See_Also: FormatSlice
 +/
private nothrow FormatSlice[] parseFormatString(in string input)
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

/++ 
 * The root formatter, based on std.stdio
 + Example:
 + ---
 + import helper.formatter;
 + void main()
 + {
 +     Formatter.writef("%s ${home}", "Hello");
 + }
 + ---
 +/
synchronized class Formatter
{

    private static FormatValueFunc[string] values_;

    /++ 
     + The getter for format values getter
     + Returns: The array of format values
     + See_Also: FormatValueFunc
     +/
    @property
    static ref FormatValueFunc[string] formatValues()
    {
        return values_;
    }

    private static auto formatBase(Char, A...)(in Char[] fmt, A args)
    {
        return format_.format(fmt, args);
    }

    /++ 
     + Format into a string
     + Params:
     +   fmt = The format.string
     +   args = Items to format
     + Returns: The processed string
     +/
    static Char[] format(Char, A...)(in Char[] fmt, A args)
    {
        auto formatString = formatBase(fmt, args);
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

    /++ 
     + Write to console by the format string
     + Params:
     +   fmt = The format string
     +   args = Items to write
     +/
    static void writef(Char, A...)(in Char[] fmt, A args)
    {
        auto formatString = formatBase(fmt, args);
        FormatSlice[] slices = parseFormatString(formatString);
        foreach (slice; slices)
        {
            if (slice.type == FormatSliceType.Variable && slice.str.length != 0)
            {
                string[] variableAndParams = slice.str.split(';');
                if (variableAndParams[0] in formatValues)
                    stdio.write(formatValues[variableAndParams[0]](variableAndParams.length == 1 ? [
                            ] : variableAndParams[1 .. $]));
                continue;
            }
            stdio.write(slice.str);
        }
    }

    /++ 
     + Format into a string
     + Params:
     +   args = Items to format
     +/
    static auto format(alias fmt, A...)(A args)
        if (isSomeString!(typeof(fmt)))
    {
        return format(fmt, args);
    }

    /++ 
     + Write to console by the format string
     + Params:
     +   args = Items to write
     +/
    static void writef(alias fmt, A...)(A args)
        if (isSomeString!(typeof(fmt)))
    {
        writef(fmt, args);
    }

    /++ 
     + Write to console by the format string and put a \n
     + Params:
     +   fmt = The format string
     +   args = Items to write
     +/
    static void writefln(Char, A...)(in Char[] fmt, A args)
    {
        writef(fmt, args);
        stdio.writeln();
    }

    /++ 
     + Write to console by the format string and put a \n
     + Params:
     +   args = Items to write
     +/
    static void writefln(alias fmt, A...)(A args)
        if (isSomeString!(typeof(fmt)))
    {
        writefln(fmt, args);
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
    catch (GitException)
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
            stdio.stdout.setColor(mixin("Colors." ~ s));
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
            stdio.stdout.setColor(T(
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
