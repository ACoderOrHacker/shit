module helper.str;

import std.stdint;
import std.ascii;
import core.stdc.string : strlen;

dstring insert(dstring original, uint32_t pos, dchar ch)
{
    return original[0 .. pos] ~ ch ~ original[pos .. $];
}

/// For C
string[] convertToStringArray(const(char)** cStrings, size_t length)
{
    string[] result;
    result.length = length;

    foreach (i; 0 .. length)
    {
        result[i] = cStrings[i][0 .. strlen(cStrings[i])].idup;
    }

    return result;
}

enum YNResult
{
    Yes,
    No,
    Invalid
}

YNResult checkYesOrNo(char ch)
{
    if (ch == '\n')
        return YNResult.No;

    if (!isAlpha(ch))
        return YNResult.Invalid;
    char lowerChar = toLower(ch);

    if (lowerChar == 'y')
        return YNResult.Yes;
    else if (lowerChar == 'n')
        return YNResult.No;
    else
        return YNResult.Invalid;
}