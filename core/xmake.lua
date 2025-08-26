add_rules("mode.release", "mode.debug")

target("lualib")
    set_kind("static")
    set_basename("lua")

    set_targetdir("$(projectdir)")
    add_files("lua/*.c|lua.c|luac.c|onelua.c")
    add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
    if is_plat("linux", "bsd", "cross") then
        add_defines("LUA_USE_LINUX")
        add_defines("LUA_DL_DLOPEN")
    elseif is_plat("macosx", "iphoneos") then
        add_defines("LUA_USE_MACOSX")
        add_defines("LUA_DL_DYLD")
    end
target_end()