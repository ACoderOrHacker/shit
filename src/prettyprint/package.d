/++
 + A user-friendly pretty printer & formatter for D
 + Example:
 + ---
 + import prettyprint;
 + struct A
 + {
 +     int i;
 +     @NonPrintable float f;
 +     B b;
 + }
 +
 + struct B
 + {
 +     long c;
 +
 +     @Printable @property
 +     string s()
 +     {
 +         return "s";
 +     }
 + }
 +
 + void main()
 + {
 +     A a(1, 2.0, B(3));
 +     pprint(a);
 +     // This will print:
 +     // A(
 +     //     i = 1,
 +     //     b = B(
 +     //         c = 3,
 +     //         s = "s"
 +     //     )
 +     // )
 + }
 + ---
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module pprint;

import std.meta;
import std.traits;
import std.array;
import std.stdio;
import std.string;
import std.ascii;

import std.exception;
import std.conv;

// ADTs
enum NonPrintable;
enum Printable;

alias PPrintFunction = void function(void*, string, string);

void pprint(A)(A arg, size_t tabSize = 4) @trusted
{
    pprintImpl(arg, " ".replicate(tabSize), "");
}

class PPrintException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

struct TypeRegistry
{
    static PPrintFunction[TypeInfo] typeNames;

    static void register(T)()
    {
        static void wrapper(void* data, string tabText, string beforeText)
        {
            pprintImpl!T(*cast(T*) data, tabText, beforeText);
        }

        typeNames[typeid(T)] = &wrapper;
    }

    static PPrintFunction getFunction(TypeInfo info)
    {
        return typeNames.get(info, null);
    }
}

private template isUserDefined(string member) // TODO: may be a better way
{
    enum bool isUserDefined =
        !(member.length >= 2 && (member[0 .. 1] == "_" || member[0 .. 2].toLower == "op")) &&
        member != "Monitor" &&
        member != "factory";
}

private template UserDefinedMembers(T)
{
    alias UserDefinedMembers = Filter!(isUserDefined, __traits(allMembers, T));
}

private template PrintableFieldNames(T)
{
    template isPrintable(alias memberName)
    {
        alias member = __traits(getMember, T, memberName);

        static if (__traits(getVisibility, member) != "public")
        {
            enum isPrintable = false;
        }
        else
        {
            enum hasNonPrintable = hasUDA!(member, NonPrintable);
            enum hasPrintable = hasUDA!(member, Printable);

            static assert(!(hasNonPrintable && hasPrintable),
                "property `" ~ T.stringof ~ "." ~ memberName ~ "` has both NonPrintable and Printable attributes");

            static if (hasNonPrintable)
            {
                enum isPrintable = false;
            }
            else static if (isCallable!member)
            {
                enum isPrintable = hasPrintable;
            }
            else
            {
                enum isPrintable = true;
            }
        }
    }

    alias PrintableFieldNames = Filter!(isPrintable, UserDefinedMembers!T);
}

private struct NoDirectParent
{
}

private template DirectParentClass(T)
{
    static if (!is(T == class))
    {
        alias DirectParentClass = NoDirectParent;
    }
    else
    {
        alias BaseClasses = BaseClassesTuple!T;

        static if (BaseClasses.length > 1)
        {
            alias DirectParentClass = BaseClasses[0];
        }
        else
        {
            alias DirectParentClass = NoDirectParent;
        }
    }
}

private string getClassRuntimeTypeidWithoutModule(T)(T obj)
{
    auto className = typeid(obj).name;
    auto shortName = className[className.lastIndexOf('.') + 1 .. $];

    return shortName;
}

private void pprintImpl(T)(T object, string, string)
        if (isBasicType!T || isSomeString!T)
{
    static if (isSomeString!T)
    {
        write("\"", object, "\"");
    }
    else
    {
        write(object);
    }
}

private void pprintImpl(T)(T object, string tabText, string beforeText)
        if ((isArray!T || isAssociativeArray!T) && !isSomeString!T)
{
    writeln("[");
    string elemBeforeText = beforeText ~ tabText;
    foreach (k, v; object)
    {
        write(beforeText, tabText);
        pprintImpl(k, tabText, elemBeforeText);
        write(" : ");
        pprintImpl(v, tabText, beforeText);
        writeln();
    }
    writeln(beforeText, "]");
}

private void pprintImpl(T, bool checkPolymorphic = true)(T object, string tabText, string beforeText,
    string className = null) if (is(T == struct) || is(T == class))
{
    if (className == null)
    {
        className = getClassRuntimeTypeidWithoutModule(object);
    }
    static if (checkPolymorphic && is(T == class))
    {
        // maybe polymorphic object
        auto id = typeid(object);
        if (id != typeid(T))
        {
            auto func = TypeRegistry.getFunction(id);
            enforce(func != null, new PPrintException("Unregistered polymorphic object"));

            func(cast(void*)&object, tabText, beforeText);
            return;
        }
    }
    string beforeElemText = beforeText ~ tabText;
    write(className, "(");

    void printClassItem(T)(T object, string name, string className)
    {
        write(beforeText, tabText, name, " = ");
        pprintImpl!(T, false)(object, tabText, beforeElemText,
            className);
    }

    void printItem(T)(T object, string name)
    {
        write(beforeText, tabText, name, " = ");
        pprintImpl!(T)(object, tabText, beforeElemText);
    }

    alias Fields = PrintableFieldNames!T;
    alias Parent = DirectParentClass!T;

    static if (Parent.stringof != "NoDirectParent")
    {
        // has parent class
        writeln();
        printClassItem(mixin("object." ~ Parent.stringof), "super", Parent.stringof);
    }
    static foreach (i, name; Fields)
    {
        writeln();
        printItem(mixin("object." ~ name), name);
    }

    static if (Fields.length > 0)
    {
        write(beforeText);
    }
    writeln(")");
}
