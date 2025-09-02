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

class Config(C, string F, R, W)
{
    static C data;
    private static Exception exception_ = null;

    alias data this;

    static string configFile;

    static this()
    {
        configFile = getConfigFile();
        read(); // read the configuration
    }

    private static void doInitiailize()
    {
        static if (__traits(hasMember, C, "initialize"))
        {
            data.initialize();
        }
    }

    static void read()
    {
        try
        {
            doInitiailize();
            readConfig!(C, R)(configFile, data);
            exception_ = null;
        }
        catch (Exception e)
        {
            exception_ = e;
            doInitiailize();
        }
    }

    static void write()
    {
        try
        {
            writeConfig!(C, W)(configFile, data);
            exception_ = null;
        }
        catch (Exception e)
        {
            exception_ = e;
        }
    }

    @property
    static ref Exception exception()
    {
        return exception_;
    }

    @property
    static bool hasException()
    {
        return exception_ !is null;
    }

    static string getConfigFile()
    {
        return buildPath(ShitInformation.configPath, F);
    }
}
