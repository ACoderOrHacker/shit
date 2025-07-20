set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.0")

set_description("A powerful and modern terminal")

includes("@builtin/xpack")

add_rules("mode.debug", "mode.release")

add_installfiles("etc/shit/*.json", {prefixdir = "etc/shit"})
set_configvar("CONFIGS_PATH", "buildPath(dirName(dirName(executablePath())), \"etc\", \"shit\")", {quote = false})

set_configdir("src/shit/configs")
add_configfiles("src/shit/configs/project.d.in")

add_includedirs("src")

target("shit")
    set_kind("binary")

    add_files("src/**.d")
target_end()

xpack("shit")
    set_description("A powerful and modern terminal")

    add_targets("shit")
xpack_end()