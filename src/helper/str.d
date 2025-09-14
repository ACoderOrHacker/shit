/++
 + C-style String utilities for shit
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.str;
@safe:
export:

import std.stdint;
import std.ascii;
import core.stdc.string : strlen;

/++ 
 + Insert a character of type Char to the original string
 + Params:
 +   original = The original string
 +   pos = The insert position of the string
 +   ch = The insert char
 + Returns: The result of inserting
 +/
auto insert(Char = dchar)(in immutable(Char)[] original, uint pos, Char ch)
{
    return original[0 .. pos] ~ ch ~ original[pos .. $];
}

/++ 
 + Convert a C-style string array to D-style
 + Params:
 +   cStrings = the C-style string
 +   length = the array length
 + Returns: The D-style string
 +/
auto convertToStringArray(Char)(const(Char)** cStrings, size_t length) @trusted
{
    alias StringType = immutable(Char)[];
    StringType[] result;
    result.length = length;

    foreach (i; 0 .. length)
    {
        result[i] = cStrings[i][0 .. strlen(cStrings[i])].idup;
    }

    return result;
}

/++ 
 + The result of Yes or No
 + See_Also: checkYesOrNo
 +/
enum YNResult
{
    Yes,
    No,
    Invalid
}

/++ 
 + Checks if the input character to yes or no
 + Params:
 +   ch = The character to check
 + Returns: The character's Yes No Status
 + See_Also: YNResult
 +/
YNResult checkYesOrNo(Char)(Char ch)
{
    if (ch == '\n')
        return YNResult.No;

    if (!isAlpha(ch))
        return YNResult.Invalid;
    Char lowerChar = toLower(ch);

    if (lowerChar == 'y')
        return YNResult.Yes;
    else if (lowerChar == 'n')
        return YNResult.No;
    else
        return YNResult.Invalid;
}