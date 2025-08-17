module pkgman.style;

import std.path;
import std.file;
import std.string;
import std.conv : to;
import shit.configs.basic;
import shit.configs.project;
import pkgman.basic;
import luaapi;

class StylePackageInfo : PackageInfo
{
    string[string] styles;
}

class StylePackage : Package
{
    final this(string file)
    {
        super(file);
    }

    override protected PackageInfo createPackageInfo()
    {
        return new StylePackageInfo;
    }

    override protected void readExtra(
        ZipArchive ar, ArchiveMember member, string name, ref PackageInfo info)
    {
        StylePackageInfo styleinfo = cast(StylePackageInfo) info;

        assert(styleinfo !is null, "Bad style info");
        if (name.startsWith("styles/") && name != "styles/")
        {
            string style = baseName(name);
            string data = cast(string) member.expandedData;

            styleinfo.styles[style] = data;
        }
    }

    override protected void writeExtra(ZipArchive ar, PackageInfo info)
    {
        StylePackageInfo styleinfo = cast(StylePackageInfo) info;

        assert(styleinfo !is null, "Bad style info");
        foreach (key, value; styleinfo.styles)
        {
            this.addMember(ar, buildPath("styles", key), value);
        }
    }

    override PackageInfo defaultPackage(string pkgtype)
    {
        PackageInfo info = super.defaultPackage(pkgtype);
        StylePackageInfo styleinfo = cast(StylePackageInfo) info;

        styleinfo.styles["main.lua"] = "";

        return info;
    }

    PackageInfo defaultPackage()
    {
        return this.defaultPackage("style");
    }

    void writeDefaultPackage() {
        writePackage(defaultPackage());
    }
}

class StyleExtensionRunner : ExtensionRunner
{
    private void runOneStyleFile(string name, string file) shared
    {
        if (!exists(file))
            throw new ExtensionRunException("extension `" ~ name ~"`(file " ~ file ~ ") not found");

        lua_State* extension = luaL_newstate();
        luaL_openlibs(extension);

        if (luaL_dofile(extension, (file ~ "\0").ptr)) // oh my god! Damn!
            // the \0 must add because lua is written by C
            {
            throw new ExtensionRunException("lua execute error: " ~ lua_tostring(extension, -1)
                    .to!string);
        }

        lua_close(extension);
    }

    override void run(string packageName, string packagePath) shared
    {
        runOneStyleFile(packageName, buildPath(packagePath, "styles", "main.lua"));
    }
}

static this()
{
    new ExtensionRunnerRegistry()
        .register!StyleExtensionRunner("style");
}
