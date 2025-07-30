module shit.helper.string;

export string replaceFirst(string input, string oldHeader, string newHeader) {
    import std.string : startsWith;

    if (input is null || oldHeader is null || newHeader is null)
        return "";
    if (input.startsWith(oldHeader)) {
        return newHeader ~ input[oldHeader.length..$];
    }
    return input;
}

@("string") unittest {
    string old = "LLL", new_ = "SHIT";
    string test1 = "LLL123456",
           test2 = "114514",
           test3 = null;

    void check(string test, string res) {
        string result = replaceFirst(test, old, new_);
        assert(result == res,
            "Failed replaceFirst(" ~ test ~ ", " ~ old ~ ", " ~ new_ ~
            "\n  Expected: " ~ res ~
            "\n  Got: " ~ result);
    };

    check(test1, "SHIT123456");
    check(test2, "114514");
    check(test3, "");
}