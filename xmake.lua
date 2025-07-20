set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.0")

set_description("A powerful and modern terminal")

includes("@builtin/xpack")

add_rules("mode.debug", "mode.release")

set_configdir("src/shit/configs")
add_configfiles("src/shit/configs/project.d.in")

add_includedirs("src")

target("executor")
    set_kind("static")

    add_files("src/shit/executor/*.d")
target_end()

target("configs")
    set_kind("static")

    add_files("src/shit/configs/*.d")
target_end()

target("shit")
    set_kind("binary")

    add_files("src/main/*.d")
    add_deps("executor")
    add_deps("configs")
target_end()

xpack("shit")
    set_description("A powerful and modern terminal")

    add_targets("shit")
xpack_end()