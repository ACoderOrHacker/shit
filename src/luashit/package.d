module luashit;

/// The shit terminal API for Lua interface

import std.string : fromStringz, toStringz; // for c-style string convertion
import std.conv;
import luaapi;
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
}
