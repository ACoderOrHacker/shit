set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.1")

set_description("A powerful and modern terminal")

includes("@builtin/xpack")

add_rules("mode.debug", "mode.release", "mode.releasedbg")

add_installfiles("etc/shit/*.json", {prefixdir = "etc/shit"})

set_configdir("src/shit/configs")
add_configfiles("src/shit/configs/project.d.in")

add_requires("lua 5.4.7", {alias = "lua54", configs = {shared = true}})

add_includedirs("src")

option("unittests")
    set_default(false)

    add_dcflags("-unittest", {tools = "dmd"})
option_end()

target("conbase")
    set_kind("shared")

    add_options("unittests")
    add_dcflags("-boundscheck=on", {force = true, tools = "dmd"})

    -- see https://github.com/stefv/dlang_moduleinfo/tree/develop
    add_dcflags("-visibility=public", {force = true, tools = "dmd"})

    add_files("src/helper/**.d")
    add_files("src/termcolor/**.d")
    add_files("src/shit/**.d")
    add_files("src/pkgman/**.d")
    add_files("src/cli/**.d")

    add_packages("lua54", {public = true})
target_end()

target("shit")
    set_kind("binary")

    add_files("src/app/app.c")
    add_deps("conbase")
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

    add_targets("shit", "conbase")
xpack_end()