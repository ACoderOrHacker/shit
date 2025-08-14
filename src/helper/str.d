module helper.str;

dstring insert(dstring original, ulong pos, dchar ch)
{
    return original[0 .. pos] ~ ch ~ original[pos .. $];
}
