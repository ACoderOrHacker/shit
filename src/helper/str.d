module helper.str;

import std.stdint;

dstring insert(dstring original, uint32_t pos, dchar ch)
{
    return original[0 .. pos] ~ ch ~ original[pos .. $];
}
