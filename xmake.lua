set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.0")

set_description("A powerful and modern terminal")

includes("@builtin/xpack")

add_rules("mode.debug", "mode.release")

add_installfiles("etc/shit/*.json", {prefixdir = "etc/shit"})

set_configdir("src/shit/configs")
add_configfiles("src/shit/configs/project.d.in")

add_requires("lua 5.3.6", {alias = "lua"})
add_requires("dub::colored", {alias = "colored"})
add_requires("dub::dlua", {alias = "dlua"})

add_includedirs("src")

option("unittests")
    set_default(false)

    add_dcflags("-unittest", {tools = "dmd"})
option_end()

target("conbase")
    set_kind("shared")

    add_options("unittests")
    add_dcflags("-boundscheck=on", {force = true})
    add_files("src/shit/**.d")
target_end()

target("pkgman")
    set_kind("shared")

    add_options("unittests")
    add_dcflags("-boundscheck=on", {force = true})
    add_files("src/pkgman/**.d")
    add_packages("lua", {public = true})
    add_packages("dlua", {public = true})
target_end()

target("shit")
    set_kind("binary")

    add_dcflags("-boundscheck=on", {force = true})
    add_files("src/main/**.d")
    add_deps("conbase", "pkgman")
    add_packages("colored")
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