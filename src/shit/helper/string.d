module shit.helper.string;

export string replaceFirst(string input, string oldHeader, string newHeader) {
    import std.string : startsWith;
    if (input.startsWith(oldHeader)) {
        return newHeader ~ input[oldHeader.length..$];
    }
    return input;
} 