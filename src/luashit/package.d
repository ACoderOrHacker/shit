module luashit;

/// The shit terminal API for Lua interface

import std.stdio : stdout;
import std.string : fromStringz, toStringz; // for c-style string convertion
import std.conv;
import luaapi;
import helper.formatter;
import shit.configs.global;

extern (C):
export:

private ref GlobalConfig getGConfig(lua_State* L)
{
    lua_getglobal(L, "gconfig");

    void* ptr;
    if (!lua_islightuserdata(L, -1))
    {
        luaL_error(L, toStringz("gconfig is not a light user data (bad gconfig)"));
    }

    ptr = lua_touserdata(L, -1);
    lua_pop(L, 1);

    ref GlobalConfig config = *(cast(GlobalConfig*) ptr);

    return config;
}

private string[] popStringArray(lua_State* L)
{
    if (!lua_istable(L, -1))
    {
        lua_pop(L, 1);
        luaL_error(L, toStringz("invoke error: there needs a string array"));
        return null;
    }

    auto tableIndex = lua_absindex(L, -1);

    lua_Integer len = lua_rawlen(L, tableIndex);
    string[] result;
    result.length = len;

    for (lua_Integer i = 1 /* lua index starts at 1 */ ; i <= len; ++i)
    {
        lua_geti(L, tableIndex, i);

        if (!lua_isstring(L, -1))
        {
            luaL_error(L, toStringz("invoke error: table[" ~ i.to!string ~ "] is not a string"));
            return null;
        }

        result[i - 1] = cast(string) fromStringz(lua_tostring(L, -1));

        lua_pop(L, 1);
    }

    return result;
}

int lset_prompts(lua_State* L)
{
    string[] prompts = popStringArray(L);
    if (prompts is null)
        return 0;

    getGConfig(L).prompts = delegate() {
        foreach (prompt; prompts)
        {
            import std.stdio;

            writeln(prompt);
        }
    };

    return 0;
}

int lon_prompts(lua_State* L)
{
    if (!lua_isfunction(L, 1))
    {
        luaL_error(L, toStringz("invoke error: there needs a function"));
        return 0;
    }

    lua_pushvalue(L, 1);
    lua_setglobal(L, toStringz("__on_prompts_callback"));

    getGConfig(L).prompts = delegate() {
        lua_getglobal(L, toStringz("__on_prompts_callback"));
        lua_pcall(L, 0, 0, 0);
    };

    return 0;
}

int lcprint(lua_State* L)
{
    import std.stdio;

    if (!lua_isstring(L, 1))
    {
        luaL_error(L, "cprint needs a string format value");
        return 0;
    }

    string formatString = cast(string) fromStringz(lua_tostring(L, 1));
    Formatter.writef(formatString);

    return 0;
}

int lcprintln(lua_State* L)
{
    int len = lcprint(L);
    stdout.writeln();

    return len;
}

int lget_format_variable(lua_State* L)
{
    if (!lua_isstring(L, 1))
    {
        luaL_error(L, "variable name must be a string");
        return 1;
    }

    string variableName = cast(string) fromStringz(lua_tostring(L, 1));
    if (variableName !in Formatter.formatValues)
        lua_pushnil(L);
    else
        lua_pushstring(L, toStringz(Formatter.formatValues[variableName]()));
    return 1;
}

int lset_format_variable(lua_State* L)
{
    if (!lua_isstring(L, 1))
    {
        luaL_error(L, "format variable name is must be a string");
        return 0;
    }

    if (!lua_isfunction(L, 2))
    {
        luaL_error(L, toStringz("format variable value is must be a function"));
        return 0;
    }

    string variableName = cast(string) fromStringz(lua_tostring(L, 1));

    if (variableName in Formatter.formatValues)
    {
        luaL_error(L, toStringz(variableName ~ " is already in Formatter"));
        return 0;
    }

    const(char)* lglobalName = toStringz("__set_format_variable__" ~ variableName);
    lua_pushvalue(L, 2);
    lua_setglobal(L, lglobalName);

    Formatter.formatValues[variableName] = delegate() {
        lua_getglobal(L, lglobalName);
        lua_pcall(L, 0, 1, 0);

        if (!lua_isstring(L, -1))
        {
            luaL_error(L, toStringz("format variable " ~ variableName ~ " returns a non-string value"));
            lua_pop(L, 1);
            return "";
        }

        string s = cast(string) fromStringz(lua_tostring(L, -1));
        lua_pop(L, 1);

        return s;
    };

    return 0;
}

void luaopen_luashit(lua_State* L, ref GlobalConfig config)
{
    void add(string name, lua_CFunction func)
    {
        lua_pushcfunction(L, func);
        lua_setglobal(L, toStringz(name));
    }

    // global config init (for api to read)
    lua_pushlightuserdata(L, &config);
    lua_setglobal(L, toStringz("gconfig"));

    luaL_checkversion(L);
    add("set_prompts", &lset_prompts);
    add("on_prompts", &lon_prompts);
    add("cprint", &lcprint);
    add("cprintln", &lcprintln);
    add("get_format_variable", &lget_format_variable);
    add("set_format_variable", &lset_format_variable);
}
