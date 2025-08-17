/*
** $Id: lua.h $
** Lua - A Scripting Language
** Lua.org, PUC-Rio, Brazil (www.lua.org)
** See Copyright Notice at the end of this file
*/

import core.stdc.limits;
import core.stdc.stddef;
import core.stdc.stdarg;
import luaapi.luaconf;

extern (C):

enum LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo, W. Celes";

enum LUA_VERSION_MAJOR_N = 5;
enum LUA_VERSION_MINOR_N = 5;
enum LUA_VERSION_RELEASE_N = 0;

enum LUA_VERSION_NUM = LUA_VERSION_MAJOR_N * 100 + LUA_VERSION_MINOR_N;
enum LUA_VERSION_RELEASE_NUM = LUA_VERSION_NUM * 100 + LUA_VERSION_RELEASE_N;

/* mark for precompiled code ('<esc>Lua') */
enum LUA_SIGNATURE = "\x1bLua";

/* option for multiple returns in 'lua_pcall' and 'lua_call' */
enum LUA_MULTRET = -1;

/*
** Pseudo-indices
** (The stack size is limited to INT_MAX/2; we keep some free empty
** space after that to help overflow detection.)
*/
enum LUA_REGISTRYINDEX = -(INT_MAX / 2 + 1000);

extern (D) auto lua_upvalueindex(T)(auto ref T i)
{
    return LUA_REGISTRYINDEX - i;
}

/* thread status */
enum LUA_OK = 0;
enum LUA_YIELD = 1;
enum LUA_ERRRUN = 2;
enum LUA_ERRSYNTAX = 3;
enum LUA_ERRMEM = 4;
enum LUA_ERRERR = 5;

struct lua_State;

/*
** basic types
*/
enum LUA_TNONE = -1;

enum LUA_TNIL = 0;
enum LUA_TBOOLEAN = 1;
enum LUA_TLIGHTUSERDATA = 2;
enum LUA_TNUMBER = 3;
enum LUA_TSTRING = 4;
enum LUA_TTABLE = 5;
enum LUA_TFUNCTION = 6;
enum LUA_TUSERDATA = 7;
enum LUA_TTHREAD = 8;

enum LUA_NUMTYPES = 9;

/* minimum Lua stack available to a C function */
enum LUA_MINSTACK = 20;

/* predefined values in the registry */
/* index 1 is reserved for the reference mechanism */
enum LUA_RIDX_GLOBALS = 2;
enum LUA_RIDX_MAINTHREAD = 3;
enum LUA_RIDX_LAST = 3;

/* type of numbers in Lua */
alias lua_Number = double;

/* type for integer functions */
alias lua_Integer = long;

/* unsigned integer type */
alias lua_Unsigned = ulong;

/* type for continuation-function contexts */
alias lua_KContext = long;

/*
** Type for C functions registered with Lua
*/
alias lua_CFunction = int function(lua_State* L);

/*
** Type for continuation functions
*/
alias lua_KFunction = int function(lua_State* L, int status, lua_KContext ctx);

/*
** Type for functions that read/write blocks when loading/dumping Lua chunks
*/
alias lua_Reader = const(char)* function(lua_State* L, void* ud, size_t* sz);

alias lua_Writer = int function(lua_State* L, const(void)* p, size_t sz, void* ud);

/*
** Type for memory-allocation functions
*/
alias lua_Alloc = void* function(void* ud, void* ptr, size_t osize, size_t nsize);

/*
** Type for warning functions
*/
alias lua_WarnFunction = void function(void* ud, const(char)* msg, int tocont);

/*
** Type used by the debug API to collect debug information
*/

/*
** Functions to be called by the debugger in specific events
*/
alias lua_Hook = void function(lua_State* L, lua_Debug* ar);

/*
** generic extra include file
*/

/*
** RCS ident string
*/
extern __gshared const(char)[] lua_ident;

/*
** state manipulation
*/
lua_State* lua_newstate(lua_Alloc f, void* ud, uint seed);
void lua_close(lua_State* L);
lua_State* lua_newthread(lua_State* L);
int lua_closethread(lua_State* L, lua_State* from);

lua_CFunction lua_atpanic(lua_State* L, lua_CFunction panicf);

lua_Number lua_version(lua_State* L);

/*
** basic stack manipulation
*/
int lua_absindex(lua_State* L, int idx);
int lua_gettop(lua_State* L);
void lua_settop(lua_State* L, int idx);
void lua_pushvalue(lua_State* L, int idx);
void lua_rotate(lua_State* L, int idx, int n);
void lua_copy(lua_State* L, int fromidx, int toidx);
int lua_checkstack(lua_State* L, int n);

void lua_xmove(lua_State* from, lua_State* to, int n);

/*
** access functions (stack -> C)
*/

int lua_isnumber(lua_State* L, int idx);
int lua_isstring(lua_State* L, int idx);
int lua_iscfunction(lua_State* L, int idx);
int lua_isinteger(lua_State* L, int idx);
int lua_isuserdata(lua_State* L, int idx);
int lua_type(lua_State* L, int idx);
const(char)* lua_typename(lua_State* L, int tp);

lua_Number lua_tonumberx(lua_State* L, int idx, int* isnum);
lua_Integer lua_tointegerx(lua_State* L, int idx, int* isnum);
int lua_toboolean(lua_State* L, int idx);
const(char)* lua_tolstring(lua_State* L, int idx, size_t* len);
lua_Unsigned lua_rawlen(lua_State* L, int idx);
lua_CFunction lua_tocfunction(lua_State* L, int idx);
void* lua_touserdata(lua_State* L, int idx);
lua_State* lua_tothread(lua_State* L, int idx);
const(void)* lua_topointer(lua_State* L, int idx);

/*
** Comparison and arithmetic functions
*/

enum LUA_OPADD = 0; /* ORDER TM, ORDER OP */
enum LUA_OPSUB = 1;
enum LUA_OPMUL = 2;
enum LUA_OPMOD = 3;
enum LUA_OPPOW = 4;
enum LUA_OPDIV = 5;
enum LUA_OPIDIV = 6;
enum LUA_OPBAND = 7;
enum LUA_OPBOR = 8;
enum LUA_OPBXOR = 9;
enum LUA_OPSHL = 10;
enum LUA_OPSHR = 11;
enum LUA_OPUNM = 12;
enum LUA_OPBNOT = 13;

void lua_arith(lua_State* L, int op);

enum LUA_OPEQ = 0;
enum LUA_OPLT = 1;
enum LUA_OPLE = 2;

int lua_rawequal(lua_State* L, int idx1, int idx2);
int lua_compare(lua_State* L, int idx1, int idx2, int op);

/*
** push functions (C -> stack)
*/
void lua_pushnil(lua_State* L);
void lua_pushnumber(lua_State* L, lua_Number n);
void lua_pushinteger(lua_State* L, lua_Integer n);
const(char)* lua_pushlstring(lua_State* L, const(char)* s, size_t len);
const(char)* lua_pushexternalstring(
    lua_State* L,
    const(char)* s,
    size_t len,
    lua_Alloc falloc,
    void* ud);
const(char)* lua_pushstring(lua_State* L, const(char)* s);
const(char)* lua_pushvfstring(lua_State* L, const(char)* fmt, va_list argp);
const(char)* lua_pushfstring(lua_State* L, const(char)* fmt, ...);
void lua_pushcclosure(lua_State* L, lua_CFunction fn, int n);
void lua_pushboolean(lua_State* L, int b);
void lua_pushlightuserdata(lua_State* L, void* p);
int lua_pushthread(lua_State* L);

/*
** get functions (Lua -> stack)
*/
int lua_getglobal(lua_State* L, const(char)* name);
int lua_gettable(lua_State* L, int idx);
int lua_getfield(lua_State* L, int idx, const(char)* k);
int lua_geti(lua_State* L, int idx, lua_Integer n);
int lua_rawget(lua_State* L, int idx);
int lua_rawgeti(lua_State* L, int idx, lua_Integer n);
int lua_rawgetp(lua_State* L, int idx, const(void)* p);

void lua_createtable(lua_State* L, int narr, int nrec);
void* lua_newuserdatauv(lua_State* L, size_t sz, int nuvalue);
int lua_getmetatable(lua_State* L, int objindex);
int lua_getiuservalue(lua_State* L, int idx, int n);

/*
** set functions (stack -> Lua)
*/
void lua_setglobal(lua_State* L, const(char)* name);
void lua_settable(lua_State* L, int idx);
void lua_setfield(lua_State* L, int idx, const(char)* k);
void lua_seti(lua_State* L, int idx, lua_Integer n);
void lua_rawset(lua_State* L, int idx);
void lua_rawseti(lua_State* L, int idx, lua_Integer n);
void lua_rawsetp(lua_State* L, int idx, const(void)* p);
int lua_setmetatable(lua_State* L, int objindex);
int lua_setiuservalue(lua_State* L, int idx, int n);

/*
** 'load' and 'call' functions (load and run Lua code)
*/
void lua_callk(
    lua_State* L,
    int nargs,
    int nresults,
    lua_KContext ctx,
    lua_KFunction k);

extern (D) auto lua_call(T0, T1, T2)(auto ref T0 L, auto ref T1 n, auto ref T2 r)
{
    return lua_callk(L, n, r, 0, null);
}

int lua_pcallk(
    lua_State* L,
    int nargs,
    int nresults,
    int errfunc,
    lua_KContext ctx,
    lua_KFunction k);

extern (D) auto lua_pcall(T0, T1, T2, T3)(auto ref T0 L, auto ref T1 n, auto ref T2 r, auto ref T3 f)
{
    return lua_pcallk(L, n, r, f, 0, null);
}

int lua_load(
    lua_State* L,
    lua_Reader reader,
    void* dt,
    const(char)* chunkname,
    const(char)* mode);

int lua_dump(lua_State* L, lua_Writer writer, void* data, int strip);

/*
** coroutine functions
*/
int lua_yieldk(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k);
int lua_resume(lua_State* L, lua_State* from, int narg, int* nres);
int lua_status(lua_State* L);
int lua_isyieldable(lua_State* L);

extern (D) auto lua_yield(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_yieldk(L, n, 0, null);
}

/*
** Warning-related functions
*/
void lua_setwarnf(lua_State* L, lua_WarnFunction f, void* ud);
void lua_warning(lua_State* L, const(char)* msg, int tocont);

/*
** garbage-collection options
*/

enum LUA_GCSTOP = 0;
enum LUA_GCRESTART = 1;
enum LUA_GCCOLLECT = 2;
enum LUA_GCCOUNT = 3;
enum LUA_GCCOUNTB = 4;
enum LUA_GCSTEP = 5;
enum LUA_GCISRUNNING = 6;
enum LUA_GCGEN = 7;
enum LUA_GCINC = 8;
enum LUA_GCPARAM = 9;

/*
** garbage-collection parameters
*/
/* parameters for generational mode */
enum LUA_GCPMINORMUL = 0; /* control minor collections */
enum LUA_GCPMAJORMINOR = 1; /* control shift major->minor */
enum LUA_GCPMINORMAJOR = 2; /* control shift minor->major */

/* parameters for incremental mode */
enum LUA_GCPPAUSE = 3; /* size of pause between successive GCs */
enum LUA_GCPSTEPMUL = 4; /* GC "speed" */
enum LUA_GCPSTEPSIZE = 5; /* GC granularity */

/* number of parameters */
enum LUA_GCPN = 6;

int lua_gc(lua_State* L, int what, ...);

/*
** miscellaneous functions
*/

int lua_error(lua_State* L);

int lua_next(lua_State* L, int idx);

void lua_concat(lua_State* L, int n);
void lua_len(lua_State* L, int idx);

enum LUA_N2SBUFFSZ = 64;
uint lua_numbertocstring(lua_State* L, int idx, char* buff);
size_t lua_stringtonumber(lua_State* L, const(char)* s);

lua_Alloc lua_getallocf(lua_State* L, void** ud);
void lua_setallocf(lua_State* L, lua_Alloc f, void* ud);

void lua_toclose(lua_State* L, int idx);
void lua_closeslot(lua_State* L, int idx);

/*
** {==============================================================
** some useful macros
** ===============================================================
*/

extern (D) auto lua_getextraspace(T)(auto ref T L)
{
    return cast(void*) cast(char*) L - LUA_EXTRASPACE;
}

extern (D) auto lua_tonumber(T0, T1)(auto ref T0 L, auto ref T1 i)
{
    return lua_tonumberx(L, i, null);
}

extern (D) auto lua_tointeger(T0, T1)(auto ref T0 L, auto ref T1 i)
{
    return lua_tointegerx(L, i, null);
}

extern (D) auto lua_pop(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_settop(L, -n - 1);
}

extern (D) auto lua_newtable(T)(auto ref T L)
{
    return lua_createtable(L, 0, 0);
}

extern (D) auto lua_pushcfunction(T0, T1)(auto ref T0 L, auto ref T1 f)
{
    return lua_pushcclosure(L, f, 0);
}

extern (D) auto lua_isfunction(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TFUNCTION;
}

extern (D) auto lua_istable(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TTABLE;
}

extern (D) auto lua_islightuserdata(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TLIGHTUSERDATA;
}

extern (D) auto lua_isnil(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TNIL;
}

extern (D) auto lua_isboolean(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TBOOLEAN;
}

extern (D) auto lua_isthread(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TTHREAD;
}

extern (D) auto lua_isnone(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) == LUA_TNONE;
}

extern (D) auto lua_isnoneornil(T0, T1)(auto ref T0 L, auto ref T1 n)
{
    return lua_type(L, n) <= 0;
}

extern (D) auto lua_pushglobaltable(T)(auto ref T L)
{
    return cast(void) lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
}

extern (D) auto lua_tostring(T0, T1)(auto ref T0 L, auto ref T1 i)
{
    return lua_tolstring(L, i, null);
}

extern (D) auto lua_insert(T0, T1)(auto ref T0 L, auto ref T1 idx)
{
    return lua_rotate(L, idx, 1);
}

/* }============================================================== */

/*
** {==============================================================
** compatibility macros
** ===============================================================
*/

extern (D) auto lua_newuserdata(T0, T1)(auto ref T0 L, auto ref T1 s)
{
    return lua_newuserdatauv(L, s, 1);
}

extern (D) auto lua_getuservalue(T0, T1)(auto ref T0 L, auto ref T1 idx)
{
    return lua_getiuservalue(L, idx, 1);
}

extern (D) auto lua_setuservalue(T0, T1)(auto ref T0 L, auto ref T1 idx)
{
    return lua_setiuservalue(L, idx, 1);
}

extern (D) auto lua_resetthread(T)(auto ref T L)
{
    return lua_closethread(L, null);
}

/* }============================================================== */

/*
** {======================================================================
** Debug API
** =======================================================================
*/

/*
** Event codes
*/
enum LUA_HOOKCALL = 0;
enum LUA_HOOKRET = 1;
enum LUA_HOOKLINE = 2;
enum LUA_HOOKCOUNT = 3;
enum LUA_HOOKTAILCALL = 4;

/*
** Event masks
*/
enum LUA_MASKCALL = 1 << LUA_HOOKCALL;
enum LUA_MASKRET = 1 << LUA_HOOKRET;
enum LUA_MASKLINE = 1 << LUA_HOOKLINE;
enum LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT;

int lua_getstack(lua_State* L, int level, lua_Debug* ar);
int lua_getinfo(lua_State* L, const(char)* what, lua_Debug* ar);
const(char)* lua_getlocal(lua_State* L, const(lua_Debug)* ar, int n);
const(char)* lua_setlocal(lua_State* L, const(lua_Debug)* ar, int n);
const(char)* lua_getupvalue(lua_State* L, int funcindex, int n);
const(char)* lua_setupvalue(lua_State* L, int funcindex, int n);

void* lua_upvalueid(lua_State* L, int fidx, int n);
void lua_upvaluejoin(lua_State* L, int fidx1, int n1, int fidx2, int n2);

void lua_sethook(lua_State* L, lua_Hook func, int mask, int count);
lua_Hook lua_gethook(lua_State* L);
int lua_gethookmask(lua_State* L);
int lua_gethookcount(lua_State* L);

struct lua_Debug
{
    int event;
    const(char)* name; /* (n) */
    const(char)* namewhat; /* (n) 'global', 'local', 'field', 'method' */
    const(char)* what; /* (S) 'Lua', 'C', 'main', 'tail' */
    const(char)* source; /* (S) */
    size_t srclen; /* (S) */
    int currentline; /* (l) */
    int linedefined; /* (S) */
    int lastlinedefined; /* (S) */
    ubyte nups; /* (u) number of upvalues */
    ubyte nparams; /* (u) number of parameters */
    char isvararg; /* (u) */
    ubyte extraargs; /* (t) number of extra arguments */
    char istailcall; /* (t) */
    int ftransfer; /* (r) index of first value transferred */
    int ntransfer; /* (r) number of transferred values */
    char[LUA_IDSIZE] short_src; /* (S) */
    /* private part */
    struct CallInfo;
    CallInfo* i_ci; /* active function */
}

/* }====================================================================== */

extern (D) string LUAI_TOSTRAUX(T)(auto ref T x)
{
    import std.conv : to;

    return to!string(x);
}

alias LUAI_TOSTR = LUAI_TOSTRAUX;

enum LUA_VERSION_MAJOR = LUAI_TOSTR(LUA_VERSION_MAJOR_N);
enum LUA_VERSION_MINOR = LUAI_TOSTR(LUA_VERSION_MINOR_N);
enum LUA_VERSION_RELEASE = LUAI_TOSTR(LUA_VERSION_RELEASE_N);

/******************************************************************************
* Copyright (C) 1994-2025 Lua.org, PUC-Rio.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/
