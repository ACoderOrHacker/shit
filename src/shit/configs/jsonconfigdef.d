module shit.configs.jsonconfigdef;
@safe:
export:

static import ascii = std.ascii;
import shit.configs.basic;
public import shit.configs.configdef;

private string toConfigItemName_(string Name)()
{
    string result;
    foreach (i, dchar ch; Name)
    {
        if (ascii.isUpper(ch))
        {
            if (i > 0) result ~= '-';
            result ~= ascii.toLower(ch);
        }
        else
        {
            result ~= ch;
        }
    }

    return result;
}

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
        return toConfigItemName_!Name();
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
        return toConfigItemName_!Name();
    }

    void writeToFile() const
    {
        writeJSON(file_, root_);
    }
}

alias JSONConfig(C, string F) = Config!(C, F, JSONReader, JSONWriter);