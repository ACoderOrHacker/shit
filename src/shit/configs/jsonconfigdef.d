module shit.configs.jsonconfigdef;
@safe:
export:

import shit.configs.basic;
public import shit.configs.configdef;

class JSONReader
{
    private JSONValue root_;

    this(string file)
    {
        root_ = readJSON(file);
    }

    T readValue(T)(string name)
    {
        return root_[name].get!T;
    }

    static string toConfigItemName(string Name)()
    {
        return Name;
    }
}

class JSONWriter
{
    private JSONValue root_ = JSONValue.emptyObject;
    private string file_;

    this(string file)
    {
        file_ = file;
    }

    void writeValue(T)(string name, T value) @trusted
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