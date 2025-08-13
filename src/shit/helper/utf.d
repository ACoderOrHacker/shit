module shit.helper.utf;

import std.utf;
import std.uni;

class RangeException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

bool isUTF8Start(ubyte c)
{
    return (c & 0xC0) != 0x80;
}

string removeNthUtf8Char(string s, size_t n)
{
    if (n >= s.count)
    {
        throw new Exception("invalid range");
    }

    size_t currentIndex = 0;
    size_t charCount = 0;
    string result;

    while (currentIndex < s.length)
    {
        size_t charLen = stride(s, currentIndex);

        if (charCount != n)
        {
            result ~= s[currentIndex .. currentIndex + charLen];
        }

        currentIndex += charLen;
        charCount++;
    }

    return result;
}

auto utf8RangeBeforeWithCombining(string str, size_t index)
{
    if (index == 0 || index > str.length)
        return null;

    size_t start = index - 1;
    while (start > 0 && !isUTF8Start(cast(ubyte) str[start]))
        start--;

    if (!isUTF8Start(cast(ubyte) str[start]))
        return null;

    auto cluster = std.uni.byGrapheme(str[start .. $]);
    if (cluster.empty)
        return null;

    auto grapheme = cluster.front;
    return str[start .. start + grapheme.length];
}
