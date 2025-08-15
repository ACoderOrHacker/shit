module shit.readline.console;

import std.stdio : File;
import std.range : repeat;
import std.conv : to;
import std.array : array;

void eraseByWidth(File stream, int displayWidth)
{
    int n = displayWidth;
    stream.writef("\x1b[%dD", n);
    foreach (_; 0 .. n)
        stream.write(" ");
    //stream.write(" ".repeat(n).array);
    stream.writef("\x1b[%dD", n);
    stream.flush();
}
