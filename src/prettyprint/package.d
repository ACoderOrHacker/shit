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

// ADTs
enum NonPrintable;
enum Printable;

void pprint(A)(A arg, size_t tabSize = 4) @trusted
{
    pprintImpl(arg, " ".replicate(tabSize), "");
}

private template isStructOrClass(T)
{
    enum isStructOrClass = is(T == struct) || is(T == class);
}

private template PrintableFieldNames(T) {
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
    alias PrintableFieldNames = Filter!(isPrintable, __traits(allMembers, T));
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

private void pprintImpl(T)(T object, string tabText, string beforeText)
    if (isStructOrClass!T)
{
    string beforeElemText = beforeText ~ tabText;
    writeln(getClassRuntimeTypeidWithoutModule(object), "(");
    foreach (name; PrintableFieldNames!T)
    {
        write(beforeText, tabText, name, " = ");
        pprintImpl(mixin("object." ~ name), tabText, beforeElemText);
        writeln();
    }
    writeln(beforeText, ")");
}