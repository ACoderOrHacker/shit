module shit.configs.jsonconfigdef;
@safe:
export:

import shit.configs.basic;
public import shit.configs.configdef;

private template isJSONArray(T)
{
    enum isJSONArray
        = isArray!T && !isSomeString!T;
}

private template elementType(T) if (isArray!T)
{
    alias elementType = typeof(T.init[0]);
}

/++ 
 + The json reader implementation for Config
 +/
class JSONReader
{
    private JSONValue root_;

    this(string file)
    {
        root_ = readJSON(file);
    }

    T readValue(T)(string name)
        if (isJSONArray!T)
    {
        alias elementOfJSONValue = elementType!T;

        JSONValue[] values = root_[name].get!(JSONValue[]);

        T array;
        array.length = values.length;
        foreach (i, value; values)
        {
            array[i] = value.get!elementOfJSONValue;
        }

        return array;
    }

    T readValue(T)(string name)
        if (!isJSONArray!T)
    {
        return root_[name].get!T;
    }

    static string toConfigItemName(string Name)()
    {
        return Name;
    }
}

/++ 
 + The json writer implementation for Config
 +/
class JSONWriter
{
    private JSONValue root_ = JSONValue.emptyObject;
    private string file_;

    this(string file)
    {
        file_ = file;
    }

    void writeValue(T)(string name, T value) @trusted
        if (isJSONArray!T)
    {
        alias elementOfJSONValue = elementType!T;

        JSONValue[] values;
        values.length = value.length;

        foreach (i, val; value)
        {
            values[i] = val;
        }
        root_.object[name] = values;
    }

    void writeValue(T)(string name, T value) @trusted
        if (!isJSONArray!T)
    {
        root_.object[name] = value;
    }

    static string toConfigItemName(string Name)()
    {
        return Name;
    }

    void writeToFile() const
    {
        writeJSON(file_, root_);
    }
}

alias JSONConfig(C, string F) = Config!(C, F, JSONReader, JSONWriter);