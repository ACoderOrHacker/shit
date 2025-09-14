/++
 + The configuration automatic reader & writer
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module shit.configs.configdef;
@safe:
export:

import std.path;
import std.traits;
import std.meta;
import shit.configs.project;

// UDA Defines

enum IgnoreItem;
struct ConfigItemName
{
    string name;
}

// Codes

/++ 
 + Reads a file to the structure
 + Params:
 +   file = The file to read
 +   data = The structure of data
 +/
void readConfig(C, Reader)(in string file, ref C data)
        if (is(C == struct) && is(Reader == class))
{
    Reader reader = new Reader(file);
    foreach (i, memberName; FieldNameTuple!C)
    {
        static if (__traits(getVisibility, mixin("C." ~ memberName)) == "public"
            && !hasUDA!(mixin("data." ~ memberName), IgnoreItem))
        {
            alias memberType = typeof(__traits(getMember, data, memberName));

            static if (hasUDA!(mixin("data." ~ memberName), ConfigItemName))
            {
                enum configItemName =
                    getUDAs!(mixin("data." ~ memberName), ConfigItemName)[0].name;
            }
            else
            {
                enum configItemName = Reader.toConfigItemName!memberName();
            }

            __traits(getMember, data, memberName) = reader.readValue!memberType(configItemName);
        }
    }
}

/++ 
 + Writes a data structure to a file
 + Params:
 +   file = The file path
 +   data = The data structure
 +/
void writeConfig(C, Writer)(in string file, in C data)
{
    Writer writer = new Writer(file);
    foreach (i, memberName; FieldNameTuple!C)
    {
        static if (__traits(getVisibility, mixin("C." ~ memberName)) == "public"
            && !hasUDA!(mixin("data." ~ memberName), IgnoreItem))
        {
            alias memberType = typeof(__traits(getMember, data, memberName));

            static if (hasUDA!(mixin("data." ~ memberName), ConfigItemName))
            {
                enum configItemName =
                    getUDAs!(mixin("data." ~ memberName), ConfigItemName)[0].name;
            }
            else
            {
                enum configItemName = Writer.toConfigItemName!memberName();
            }

            writer.writeValue!memberType(configItemName, __traits(getMember, data, memberName));
        }
    }

    writer.writeToFile();
}

/++ 
 + Configuration class, auto read & write
 +/
class Config(C, string F, R, W)
{
    static C data;
    private static Exception exception_ = null;
    private static string baseDir_ = null;

    alias data this;

    // singleton disable functions
    @disable this();
    @disable void opAssign(Config!(C, F, R, W)) {}

    static this()
    {
        read(); // read the configuration
    }

    private static void doInitiailize()
    {
        static if (__traits(hasMember, C, "initialize"))
        {
            data.initialize();
        }
    }

    /++ 
     + Auto-read the configuration
     + Params:
     +   baseDir = The directory of the file in
     +/
    static void read(in string baseDir = ShitInformation.configPath)
    {
        try
        {
            doInitiailize();
            readConfig!(C, R)(getConfigFile(baseDir), data);
            baseDir_ = baseDir;
            exception_ = null;
        }
        catch (Exception e)
        {
            exception_ = e;
            baseDir_ = null;
            doInitiailize();
        }
    }

    /++ 
     + Auto-write the configuration
     +/
    static void write()
    {
        try
        {
            writeConfig!(C, W)(getConfigFile(baseDir_), data);
            exception_ = null;
        }
        catch (Exception e)
        {
            exception_ = e;
        }
    }

    /++ 
     + Get the exception when reading or writing
     + Or get the reference of the exception
     + Returns: The reference of the exception
     +/
    @property
    static ref Exception exception()
    {
        return exception_;
    }

    /++ 
     + Get current base directory
     + Returns: The base directory
     +/
    @property
    static string baseDir()
    {
        return baseDir_;
    }

    /++ 
     + Checks if it has the exception
     + Returns: Returns true if has an exception, or false
     +/
    @property
    static bool hasException()
    {
        return exception_ !is null;
    }

    /++ 
     + Generate configuration file directory by given base directory
     + Params:
     +   baseDir = The base directory
     + Returns: 
     +/
    static string getConfigFile(string baseDir)
    {
        return buildPath(baseDir, F);
    }
}
