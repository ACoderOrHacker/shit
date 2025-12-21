/++
 + Stack helpers, make life easier.
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module hlvm.base.stack;

import std.container.slist;

class StackNoElementsException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

/++ 
 + Stack, provides push, pop and top, based on `SList`
 +/
struct Stack(T)
{
    SList!T slist;
    alias slist this;

    /++ 
     + Push a data to this stack
     + Params:
     +   data = The data
     +/
    void push(T data) nothrow
    {
        try
        {
            slist.insertFront(data);
        }
        catch (Exception)
        {
        }
    }

    /++ 
     + Push a initial data into the stack
     +/
    void push()
    {
        slist.insertFront(T.init);
    }

    /++ 
     + Pop a data from stack
     + Returns: The data
     + Throws: `StackNoElementsException` if the stack is empty
     +/
    T pop()
    {
        if (slist.empty)
            throw new StackNoElementsException("no elements");
        auto data = slist.front;
        slist.removeFront();
        return data;
    }

    @property ref T top()
    {
        if (slist.empty)
            throw new StackNoElementsException("no elements");
        return slist.front;
    }
}

unittest
{
    import std.exception, std.stdio, std.math;

    {
        writeln("1. basic usage");
        auto stack = Stack!int();

        assert(stack.empty);
        assert(stack.slist.empty);

        stack.push(10);
        assert(!stack.empty);
        assert(stack.top == 10);

        stack.push(20);
        assert(stack.top == 20);

        stack.push(30);
        assert(stack.top == 30);

        assert(stack.pop == 30);
        assert(stack.top == 20);

        assert(stack.pop == 20);
        assert(stack.top == 10);

        assert(stack.pop == 10);
        assert(stack.empty);
    }

    {
        writeln("2. empty stack check");
        auto stack = Stack!string();

        bool exceptionThrown = false;
        try
        {
            auto x = stack.pop();
        }
        catch (StackNoElementsException e)
        {
            exceptionThrown = true;
            assert(e.msg == "no elements");
        }
        catch (Exception e)
        {
            writeln("ERROR: invalid exception: ", e.classinfo.name);
        }
        assert(exceptionThrown, "Should throw StackNoElementsException");

        exceptionThrown = false;
        try
        {
            auto x = stack.top();
        }
        catch (StackNoElementsException e)
        {
            exceptionThrown = true;
            assert(e.msg == "no elements");
        }
        assert(exceptionThrown, "Should throw StackNoElementsException");
    }

    {
        writeln("3. struct/string... type check");

        {
            auto stack = Stack!string();
            stack.push("hello");
            stack.push("world");
            assert(stack.top == "world");
            assert(stack.pop == "world");
            assert(stack.pop == "hello");
        }

        {
            auto stack = Stack!double();
            stack.push(3.14);
            stack.push(2.71);
            assert(stack.top.isClose(2.71));
            assert(stack.pop.isClose(2.71));
            assert(stack.pop.isClose(3.14));
        }

        {
            struct Point
            {
                int x, y;
            }

            auto stack = Stack!Point();
            stack.push(Point(1, 2));
            stack.push(Point(3, 4));
            assert(stack.top.x == 3 && stack.top.y == 4);
            auto pop1 = stack.pop;
            assert(pop1.x == 3 && pop1.y == 4);
            auto pop2 = stack.pop;
            assert(pop2.x == 1 && pop2.y == 2);
        }
    }

    {
        writeln("4. LIFO check");
        auto stack = Stack!int();

        foreach (i; 1 .. 11)
        {
            stack.push(i);
        }

        for (int expected = 10; expected >= 1; expected--)
        {
            assert(stack.top == expected);
            assert(stack.pop == expected);
        }

        assert(stack.empty);
    }

    {
        writeln("5. Huge of elements");
        auto stack = Stack!int();
        const int COUNT = 10000;

        foreach (i; 0 .. COUNT)
        {
            stack.push(i);
        }

        for (int i = COUNT - 1; i >= 0; i--)
        {
            assert(stack.pop == i);
        }

        assert(stack.empty);
    }

    {
        writeln("6. mix operations");
        auto stack = Stack!int();

        stack.push(1);
        stack.push(2);
        stack.push(3);

        assert(stack.pop == 3);
        assert(stack.pop == 2);

        stack.push(4);
        stack.push(5);

        assert(!stack.empty);
        assert(stack.top == 5);

        assert(stack.pop == 5);
        assert(stack.pop == 4);
        assert(stack.pop == 1);

        assert(stack.empty);
    }

    {
        writeln("7. reference value");
        auto stack = Stack!int();
        stack.push(100);

        {
            ref topValue = stack.top;
            topValue = 200;
            assert(stack.top == 200);
        }

        int x = stack.pop();
        assert(x == 200);

        stack.push(10);
        stack.push(20);
        assert(stack.pop + stack.pop == 30); // 20 + 10
    }

    {
        writeln("8. edge check");

        {
            auto stack = Stack!int();
            stack.push(42);
            assert(stack.top == 42);
            assert(stack.pop == 42);
            assert(stack.empty);

            bool threw = false;
            try
            {
                stack.pop();
            }
            catch (StackNoElementsException)
            {
                threw = true;
            }
            assert(threw);
        }

        {
            auto stack = Stack!int();
            stack.push(1);
            stack.push(2);
            stack.pop();
            stack.pop();
            assert(stack.empty);

            stack.push(3);
            assert(stack.top == 3);
            assert(stack.pop == 3);
        }
    }

    {
        writeln("9. alias this check");
        auto stack = Stack!int();

        assert(stack.empty);

        stack.push(1);
        stack.push(2);

        assert(stack.front == stack.top);

    }

    {
        writeln("10. performance");
        import std.datetime.stopwatch : StopWatch, AutoStart;

        auto sw = StopWatch(AutoStart.yes);
        auto stack = Stack!int();

        const int OPERATIONS = 100000;

        foreach (i; 0 .. OPERATIONS)
        {
            stack.push(i);
        }

        auto pushTime = sw.peek.total!"msecs";
        writeln("Push ", OPERATIONS, " elements for ", pushTime, " ms");

        sw.reset();
        foreach (i; 0 .. OPERATIONS)
        {
            stack.pop();
        }

        auto popTime = sw.peek.total!"msecs";
        writeln("Pop ", OPERATIONS, " elements for ", popTime, " ms");

        assert(stack.empty);
        writeln("per operation: ", (pushTime + popTime) / (OPERATIONS * 2.0), " ms");
    }

    {
        writeln("11. class check");

        class MyClass
        {
            int value;
            this(int v)
            {
                value = v;
            }
        }

        auto stack = Stack!MyClass();

        stack.push(new MyClass(1));
        stack.push(new MyClass(2));

        assert(stack.pop.value == 2);
        assert(stack.pop.value == 1);

        stack.push(null);
        assert(stack.top is null);
        assert(stack.pop is null);
    }

    {
        writeln("12. exception message check");
        auto stack = Stack!int();

        try
        {
            stack.pop();
            assert(false, "Should throw `StackNoElementsException`");
        }
        catch (StackNoElementsException e)
        {
            writeln("message: ", e.msg);
            assert(e.msg == "no elements");
        }

        try
        {
            auto x = stack.top();
            assert(false, "Should throw");
        }
        catch (StackNoElementsException e)
        {
            writeln("message: ", e.msg);
            assert(e.msg == "no elements");
        }
    }
    {
        writeln("13. useable after throwing exceptions");
        auto stack = Stack!int();

        bool exceptionOccurred = false;
        try
        {
            stack.pop();
        }
        catch (StackNoElementsException)
        {
            exceptionOccurred = true;
        }
        assert(exceptionOccurred);

        assert(stack.empty);

        stack.push(10);
        assert(stack.top == 10);
        assert(stack.pop == 10);
        assert(stack.empty);
    }
}
