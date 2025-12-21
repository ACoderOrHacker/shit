/++
 + Array helpers, make life easier.
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module hlvm.base.array;

import std.container.array;

/++ 
 + Throws on no element found (usually on empty array)
 +/
class ArrayElementNotFoundException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

/++ 
 + Array helpers, provides a auto-reserve array
 + Reserve when writing data
 +/
struct HLVMArray(T)
{
    Array!T array;
    alias array this;

    this(Args...)(Args args)
    {
        array = Array!T(args);
    }

    void opIndexAssign(T data, size_t i) nothrow
    {
        size_t oldCapacity = array.capacity;
        size_t oldLength = array.length;
        if (i >= oldLength)
        {
            if (i >= array.capacity)
            {
                size_t newCapacity = oldCapacity == 0 ? 10 : oldCapacity * 2;
                array.reserve(newCapacity);
            }

            array.length = i + 1;
        }

        array[i] = data;
    }

    ref inout(T) opIndex(size_t i) inout
    {
        if (i >= array.length)
            throw new ArrayElementNotFoundException("out of range");

        return array[i];
    }

    /++ 
     + Returns: The first element of the array
     + Throws: `ArrayElementNotFoundException` if no element
     +/
    @property ref inout(T) front() inout
    {
        if (array.empty)
            throw new ArrayElementNotFoundException("no element in array");
        return array.front;
    }

    /++ 
     + Returns: The last element of the array
     + Throws: `ArrayElementNotFoundException` if no element
     +/
    @property ref inout(T) back() inout
    {
        if (array.empty)
            throw new ArrayElementNotFoundException("no element in array");
        return array.back;
    }
}

@("hlvm.base.array") unittest
{
    import std.exception, std.range, std.stdio;

    {
        writeln("1. basic usage");
        auto arr = HLVMArray!int();
        assert(arr.length == 0);
        assert(arr.empty);

        arr[0] = 10;
        assert(arr.length == 1);
        assert(arr[0] == 10);

        arr[5] = 20;
        assert(arr.length >= 6);
        assert(arr[5] == 20);

        assert(arr[1] == 0);
        writeln("unittest 1 done.");
    }

    {
        writeln("2. bounds check");
        auto arr = HLVMArray!int(1, 2, 3);

        assert(arr[0] == 1);
        assert(arr[2] == 3);

        assertThrown!ArrayElementNotFoundException({ writeln(arr[3]); }());

        auto emptyArr = HLVMArray!int();
        assertThrown!ArrayElementNotFoundException({ writeln(emptyArr[0]); }());
        writeln("unittest 2 done.");
    }

    {
        writeln("3. front/back check");
        auto arr = HLVMArray!int(1, 2, 3, 4, 5);
        assert(arr.front == 1);
        assert(arr.back == 5);

        arr.front = 10;
        arr.back = 50;
        assert(arr[0] == 10);
        assert(arr[4] == 50);

        auto emptyArr = HLVMArray!int();
        assertThrown!ArrayElementNotFoundException({ emptyArr.front(); }());
        assertThrown!ArrayElementNotFoundException({ emptyArr.back(); }());

        auto singleArr = HLVMArray!int(42);
        assert(singleArr.front == 42);
        assert(singleArr.back == 42);
        writeln("unittest 3 done.");
    }

    {
        writeln("4. Auto-reserve check");
        auto arr = HLVMArray!int();

        arr[100] = 100;

        assert(arr.capacity >= 101);

        for (size_t i = 0; i < 100; i++)
        {
            assert(arr[i] == 0);
        }
        assert(arr[100] == 100);

        writeln("unittest 4 done.");
    }

    {
        writeln("5. struct/string... type check");
        auto strArr = HLVMArray!string();
        strArr[3] = "hello";
        assert(strArr.length >= 4);
        assert(strArr[0] == "");
        assert(strArr[3] == "hello");

        struct Point
        {
            int x, y;
        }

        auto pointArr = HLVMArray!Point();
        pointArr[2] = Point(1, 2);
        assert(pointArr[0] == Point(0, 0));
        assert(pointArr[2] == Point(1, 2));
        writeln("unittest 5 done.");
    }

    {
        writeln("6. alias this check");
        auto arr = HLVMArray!int(1, 2, 3);

        arr ~= 4;
        assert(arr.length == 4);
        assert(arr.back == 4);

        arr.insertBack(5);
        assert(arr.length == 5);
        assert(arr.back == 5);

        int sum = 0;
        foreach (x; arr)
        {
            sum += x;
        }
        assert(sum == 1 + 2 + 3 + 4 + 5);

        auto slice = arr[1 .. 3];
        assert(slice.length == 2);
        assert(slice[0] == 2);
        assert(slice[1] == 3);

        writeln("unittest 6 done.");
    }

    {
        writeln("7. writing check");
        auto arr = HLVMArray!int();

        for (int i = 0; i < 100; i++)
        {
            arr[i] = i * 2;
        }

        for (int i = 0; i < 100; i++)
        {
            assert(arr[i] == i * 2);
        }
        writeln("unittest 7 done.");
    }

    {
        writeln("8. `const` check");
        const auto arr = HLVMArray!int(1, 2, 3);

        assert(arr[0] == 1);
        assert(arr.front == 1);
        assert(arr.back == 3);

        assertThrown!ArrayElementNotFoundException({ int x = arr[10]; }());
        writeln("unittest 8 done.");
    }

    {
        writeln("9. edge check");
        auto arr = HLVMArray!int();
        size_t largeIndex = 1_000_000;
        arr[largeIndex] = 999;
        assert(arr.length > largeIndex);
        assert(arr[largeIndex] == 999);
        writeln("unittest 9 done.");
    }

    {
        writeln("10. multiple writing");
        auto arr = HLVMArray!int();
        arr[5] = 100;
        assert(arr[5] == 100);

        arr[5] = 200;
        assert(arr[5] == 200);

        arr = HLVMArray!int(1, 2, 3);
        arr[2] = 30;
        assert(arr.back == 30);

        arr[1] = 20;
        assert(arr[1] == 20);
        writeln("unittest 10 done.");
    }

    {
        writeln("11. exception message check");
        auto arr = HLVMArray!int();

        try
        {
            arr.front();
            assert(false, "Should have thrown");
        }
        catch (ArrayElementNotFoundException e)
        {
            assert(e.msg == "no element in array");
        }

        try
        {
            int x = arr[100];
            assert(false, "Should have thrown");
        }
        catch (ArrayElementNotFoundException e)
        {
            assert(e.msg == "out of range");
        }
        writeln("unittest 11 done.");
    }
}
