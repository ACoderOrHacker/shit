module shit.configs.basic;

import std.json;
import std.file : read, rename;
import std.stdio : File;

export class SafeWriteException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export JSONValue readJSON(string path)
{
    auto content = cast(string) read(path);
    return parseJSON(content);
}

export void writeJSON(string path, JSONValue value, bool safeWrite = false)
{
    File f;
    if (safeWrite)
        f = File(path ~ ".tmp", "w"); // add tmp file
    else
        f = File(path, "w");
    f.write(value.toPrettyString);
    f.close();

    if (safeWrite)
    {
        try
        {
            rename(path ~ ".tmp", path); // rename tmp file
        }
        catch (Exception e)
        {
            throw new SafeWriteException("failed to write json file: " ~ e.msg);
        }
    }
}
