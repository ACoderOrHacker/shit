set_xmakever("2.8.7")
set_project("shit")

set_version("0.1.0")

set_description("A powerful and modern terminal")

-- set_toolchains("dmd") -- -H option only for dmd
includes("@builtin/xpack")

add_rules("mode.debug", "mode.release")

add_installfiles("etc/shit/*.json", {prefixdir = "etc/shit"})

set_configdir("src/shit/configs")
add_configfiles("src/shit/configs/project.d.in")

add_includedirs("src")

target("shit")
    set_kind("binary")

    add_files("src/**.d")
--[[
    add_dcflags("-H")
    before_build(function (target)
        os.cd("$(builddir)")
    end)

    after_build(function (target)
        if not os.exists("$(builddir)/interfaces") then
            os.mkdir("$(builddir)/interfaces")
        end
        os.mv("$(builddir)/*.di", "$(builddir)/interfaces")
    end)--]]
target_end()

xpack("shit")
    set_description("A powerful and modern terminal")
    set_author("ACoderOrHacker")
    set_license("Apache-2.0")
    set_licensefile("LICENSE")
    set_title("The SHIT terminal")

    set_formats("zip", "targz", "nsis", "runself", "deb")

    set_basename("shit-$(version)-$(plat)-$(arch)")

    add_installfiles("LICENSE")
    add_installfiles("README.md")

    add_sourcefiles("src/(**.d)")
    add_sourcefiles(".github/(**.yml)")
    add_sourcefiles("etc")

    add_targets("shit")
xpack_end()