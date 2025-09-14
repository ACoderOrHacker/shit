/++
 + Exit utilities for shit
 + Examples:
 + ---
 + import helper.exit;
 +
 + void foo()
 + {
 +     exit(0);
 + }
 +
 + int main()
 + {
 +     try
 +     {
 +         foo();
 +     }
 +     catch (ExitSignal e)
 +     {
 +         return e;
 +     }
 + }
 + ---
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.exit;
@safe:
export:

/++ 
 + Exception thrown by [exit]
 + Catch it on your main function
 +/
class ExitSignal : Exception
{
    this(int code)
    {
        super("Exit signal");
    }

    private int code;

    public int getCode()
    {
        return this.code;
    }

    alias getCode this;
}

/++ 
 + Exit by exceptions
 + Throws: *always* throws [ExitSignal]
 + Params:
 +   code = the exit code
 + See_Also: ExitSignal
 +/
void exit(in int code)
{
    throw new ExitSignal(code);
}
