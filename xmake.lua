set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.2")

set_description("A powerful and modern terminal")

includes("@builtin/xpack") -- for packing
includes("xmake/dub.rules.lua") -- for modes

-- modes

if is_mode("debug") then
    add_rules("dub.options.debugMode", "dub.options.debugInfo")
elseif is_mode("release") then
    add_rules("dub.options.releaseMode", "dub.options.optimize", "dub.options.inline")
elseif is_mode("releasedbg") then
    add_rules("dub.options.releaseMode", "dub.options.debugInfo",
        "dub.options.optimize", "dub.options.inline")
elseif is_mode("unittests") then
    add_rules("dub.options.unittests", "dub.options.debugMode", "dub.options.debugInfo")
elseif is_mode("profile") then
    add_rules("dub.options.debugInfo", "dub.options.optimize", "dub.options.inline",
        "dub.options.profile")
elseif is_mode("profile-gc") then
    add_rules("dub.options.debugInfo", "dub.options.profileGC")
end

add_installfiles("etc/shit/(**.json)", {prefixdir = "etc/shit"})

add_requires("lua 5.4.7", {alias = "lua54", configs = {shared = true}})
add_requires("libcurl", {configs = {shared = true}})

set_configdir("$(projectdir)/src/")
add_configfiles("src/config.d.in")

add_includedirs("src")

target("shit")
    set_kind("binary")

    add_files("src/**.d")
    add_packages("lua54", "libcurl")
target_end()

xpack("shit")
    set_description("A powerful and modern terminal")
    set_author("ACoderOrHacker")
    set_license("Apache-2.0")
    set_licensefile("LICENSE")
    set_title("The SHIT terminal")

    set_iconfile("res/logo.ico")

    set_formats("zip", "targz", "nsis", "runself")

    set_basename("shit-$(version)-$(plat)-$(arch)")

    add_installfiles("LICENSE")
    add_installfiles("README.md")
    add_installfiles("NOTICE.md")

    add_sourcefiles("src/(**.d)")
    add_sourcefiles(".github/(**.yml)")
    add_sourcefiles("etc")

    add_targets("shit")
xpack_end()