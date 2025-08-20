module pkgman.style;

import std.path;
import std.file;
import std.string;
import std.conv : to;
import shit.configs.basic;
import shit.configs.project;
import pkgman.basic;
import luaapi;
import luashit;

class StylePackageInfo : PackageInfo
{
    string[string] styles;
}

synchronized class StylePackage : Package
{
    final this(string file)
    {
        super(file);
    }

    final this()
    {
    }

    @property
    override string packageType()
    {
        return "style";
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

    override PackageInfo defaultPackage()
    {
        PackageInfo info = super.defaultPackage();
        StylePackageInfo styleinfo = cast(StylePackageInfo) info;

        styleinfo.styles["main.lua"] = "";

        return info;
    }
}

class StyleExtensionRunner : ExtensionRunner
{
    private void runOneStyleFile(string name, string file, ref GlobalConfig config) shared
    {
        extensions[name] = luaL_newstate();
        if (!exists(file))
            throw new ExtensionRunException("extension `" ~ name ~ "`(file " ~ file ~ ") not found");

        lua_State* extension = extensions[name];
        luaL_openlibs(extension);
        luaopen_luashit(extension, config);

        if (luaL_dofile(extension, toStringz(file)) != LUA_OK)
        {
            throw new ExtensionRunException("lua execute error: " ~ lua_tostring(extension, -1)
                    .to!string);
        }
    }

    override void run(string packageName, string packagePath, ref GlobalConfig config) shared
    {
        runOneStyleFile(packageName, buildPath(packagePath, "styles", "main.lua"), config);
    }

    override void destroy(string packageName, string packagePath, ref GlobalConfig config) shared
    {
        if (packageName !in extensions)
            return;
        lua_close(extensions[packageName]);
    }

    private static lua_State*[string] extensions;
}

static this()
{
    registerExtension!(StyleExtensionRunner, StylePackage)("style");
}
