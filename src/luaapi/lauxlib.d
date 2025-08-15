/*
** $Id: lauxlib.h $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/

import core.stdc.config;
import core.stdc.stddef;
import core.stdc.stdio;
import luaapi.lua;
import luaapi.luaconf;

extern (C):

/* global table */
enum LUA_GNAME = "_G";

/* extra error code for 'luaL_loadfilex' */
enum LUA_ERRFILE = LUA_ERRERR + 1;

/* key, in the registry, for table of loaded modules */
enum LUA_LOADED_TABLE = "_LOADED";

/* key, in the registry, for table of preloaded loaders */
enum LUA_PRELOAD_TABLE = "_PRELOAD";

struct luaL_Reg
{
    const(char)* name;
    lua_CFunction func;
}

enum LUAL_NUMSIZES = lua_Integer.sizeof * 16 + lua_Number.sizeof;

void luaL_checkversion_(lua_State* L, lua_Number ver, size_t sz);

extern (D) auto luaL_checkversion(T)(auto ref T L)
{
    return luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
}

int luaL_getmetafield(lua_State* L, int obj, const(char)* e);
int luaL_callmeta(lua_State* L, int obj, const(char)* e);
const(char)* luaL_tolstring(lua_State* L, int idx, size_t* len);
int luaL_argerror(lua_State* L, int arg, const(char)* extramsg);
int luaL_typeerror(lua_State* L, int arg, const(char)* tname);
const(char)* luaL_checklstring(lua_State* L, int arg, size_t* l);
const(char)* luaL_optlstring(
    lua_State* L,
    int arg,
    const(char)* def,
    size_t* l);
lua_Number luaL_checknumber(lua_State* L, int arg);
lua_Number luaL_optnumber(lua_State* L, int arg, lua_Number def);

lua_Integer luaL_checkinteger(lua_State* L, int arg);
lua_Integer luaL_optinteger(lua_State* L, int arg, lua_Integer def);

void luaL_checkstack(lua_State* L, int sz, const(char)* msg);
void luaL_checktype(lua_State* L, int arg, int t);
void luaL_checkany(lua_State* L, int arg);

int luaL_newmetatable(lua_State* L, const(char)* tname);
void luaL_setmetatable(lua_State* L, const(char)* tname);
void* luaL_testudata(lua_State* L, int ud, const(char)* tname);
void* luaL_checkudata(lua_State* L, int ud, const(char)* tname);

void luaL_where(lua_State* L, int lvl);
int luaL_error(lua_State* L, const(char)* fmt, ...);

int luaL_checkoption(
    lua_State* L,
    int arg,
    const(char)* def,
    const(char*)* lst);

int luaL_fileresult(lua_State* L, int stat, const(char)* fname);
int luaL_execresult(lua_State* L, int stat);

/* predefined references */
enum LUA_NOREF = -2;
enum LUA_REFNIL = -1;

int luaL_ref(lua_State* L, int t);
void luaL_unref(lua_State* L, int t, int ref_);

int luaL_loadfilex(lua_State* L, const(char)* filename, const(char)* mode);

extern (D) auto luaL_loadfile(T0, T1)(auto ref T0 L, auto ref T1 f)
{
    return luaL_loadfilex(L, f, NULL);
}

int luaL_loadbufferx(
    lua_State* L,
    const(char)* buff,
    size_t sz,
    const(char)* name,
    const(char)* mode);
int luaL_loadstring(lua_State* L, const(char)* s);

lua_State* luaL_newstate();

uint luaL_makeseed(lua_State* L);

lua_Integer luaL_len(lua_State* L, int idx);

void luaL_addgsub(
    luaL_Buffer* b,
    const(char)* s,
    const(char)* p,
    const(char)* r);
const(char)* luaL_gsub(
    lua_State* L,
    const(char)* s,
    const(char)* p,
    const(char)* r);

void luaL_setfuncs(lua_State* L, const(luaL_Reg)* l, int nup);

int luaL_getsubtable(lua_State* L, int idx, const(char)* fname);

void luaL_traceback(lua_State* L, lua_State* L1, const(char)* msg, int level);

void luaL_requiref(
    lua_State* L,
    const(char)* modname,
    lua_CFunction openf,
    int glb);

/*
** ===============================================================
** some useful macros
** ===============================================================
*/

extern (D) auto luaL_newlibtable(T0, T1)(auto ref T0 L, auto ref T1 l)
{
    return lua_createtable(L, 0, l.sizeof / (l[0]).sizeof - 1);
}

extern (D) auto luaL_argcheck(T0, T1, T2, T3)(auto ref T0 L, auto ref T1 cond, auto ref T2 arg, auto ref T3 extramsg)
{
    return cast(void) luai_likely(cond) || luaL_argerror(L, arg, extramsg);
}

extern (D) auto luaL_argexpected(T0, T1, T2, T3)(auto ref T0 L, auto ref T1 cond, auto ref T2 arg, auto ref T3 tname)
{
    return cast(void) luai_likely(cond) || luaL_typeerror(L, arg, tname);
}

extern (D) auto luaL_checkstring(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return luaL_checklstring(L, n, NULL);
}

extern (D) auto luaL_optstring(T0, T1, T2)(auto ref T0 L, auto ref T1 n, auto ref T2 d)
{
    return luaL_optlstring(L, n, d, NULL);
}

extern (D) auto luaL_typename(T0, T1)(auto ref T0 L, auto ref T1 i)
{
    return lua_typename(L, lua_type(L, i));
}

extern (D) auto luaL_dofile(T0, T1)(auto ref T0 L, auto ref T1 fn)
{
    return luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0);
}

extern (D) auto luaL_dostring(T0, T1)(auto ref T0 L, auto ref T1 s)
{
    return luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0);
}

extern (D) auto luaL_getmetatable(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_getfield(L, LUA_REGISTRYINDEX, n);
}

extern (D) auto luaL_opt(T0, T1, T2, T3)(auto ref T0 L, auto ref T1 f, auto ref T2 n, auto ref T3 d)
{
    return lua_isnoneornil(L, n) ? d : f(L, n);
}

extern (D) auto luaL_loadbuffer(T0, T1, T2, T3)(auto ref T0 L, auto ref T1 s, auto ref T2 sz, auto ref T3 n)
{
    return luaL_loadbufferx(L, s, sz, n, NULL);
}

/*
** Perform arithmetic operations on lua_Integer values with wrap-around
** semantics, as the Lua core does.
*/

/* push the value used to represent failure/error */

alias luaL_pushfail = lua_pushnil;

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/

struct luaL_Buffer
{
    char* b; /* buffer address */
    size_t size; /* buffer size */
    size_t n; /* number of characters in buffer */
    lua_State* L;

    /* ensure maximum alignment for buffer */
    /* initial buffer */
    union _Anonymous_0
    {
        lua_Number n;
        double u;
        void* s;
        lua_Integer i;
        c_long l;
        char[1024] b;
    }

    _Anonymous_0 init;
}

extern (D) auto luaL_bufflen(T)(auto ref T bf)
{
    return bf.n;
}

extern (D) auto luaL_buffaddr(T)(auto ref T bf)
{
    return bf.b;
}

void luaL_buffinit(lua_State* L, luaL_Buffer* B);
char* luaL_prepbuffsize(luaL_Buffer* B, size_t sz);
void luaL_addlstring(luaL_Buffer* B, const(char)* s, size_t l);
void luaL_addstring(luaL_Buffer* B, const(char)* s);
void luaL_addvalue(luaL_Buffer* B);
void luaL_pushresult(luaL_Buffer* B);
void luaL_pushresultsize(luaL_Buffer* B, size_t sz);
char* luaL_buffinitsize(lua_State* L, luaL_Buffer* B, size_t sz);

extern (D) auto luaL_prepbuffer(T)(auto ref T B)
{
    return luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
}

/* }====================================================== */

/*
** {======================================================
** File handles for IO library
** =======================================================
*/

/*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*/

enum LUA_FILEHANDLE = "FILE*";

struct luaL_Stream
{
    FILE* f; /* stream (NULL for incompletely created streams) */
    lua_CFunction closef; /* to close stream (NULL for closed streams) */
}

/* }====================================================== */

/*
** {============================================================
** Compatibility with deprecated conversions
** =============================================================
*/

/* }============================================================ */
