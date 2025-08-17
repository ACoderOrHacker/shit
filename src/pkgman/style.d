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

class StylePackage : Package!"style"
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

    override void install()
    {
        StylePackageInfo styleinfo = cast(StylePackageInfo) this.readPackage();
        assert(styleinfo !is null, "Style implements bad");

        string etcPath = shitConfigsPath();
        string stylesPath = buildPath(etcPath, "styles");
        foreach (key, value; styleinfo.styles)
        {
            if (!key.endsWith(".lua"))
            {
                // not lua extension
                throw new PackageInstallException(
                    "on package `" ~ key ~ "`: Not a valid style extension (Lua file)");
            }
            string styleFile = buildPath(stylesPath, key);

            try
            {
                write(styleFile, cast(ubyte[]) value);
            }
            catch (FileException e)
            {
                throw new PackageInstallException("on package `" ~ key ~ "`: " ~ e.msg);
            }
        }

    }
}

private string[] getStyles()
{
    JSONValue value;
    string[] styles;
    try
    {
        value = readJSON(buildPath(shitConfigsPath(), "styles", "config.json"));
    }
    catch (FileException e)
    {
        throw new ExtensionRunException("styles configure file not found: " ~ e.msg);
    }
    catch (JSONException e)
    {
        throw new ExtensionRunException("bad styles configure file");
    }

    try
    {
        JSONValue stylesV = value["styles"];
        if (stylesV.type != JSONType.array)
            throw new ExtensionRunException("styles configure file: styles is not an array");

        JSONValue[] stylesValue = stylesV.get!(JSONValue[]);
        styles.length = stylesValue.length;

        foreach (i, styleValue; stylesValue)
        {
            if (styleValue.type != JSONType.string)
            {
                throw new ExtensionRunException(
                    "styles configure file: index `" ~ i.to!string ~ "` is not a string");
            }
            styles[i] = styleValue.get!string;
        }
    }
    catch (JSONException e)
    {
        throw new ExtensionRunException(e.msg);
    }

    return styles;
}

class StyleExtensionRunner : ExtensionRunner
{
    private void runOneStyleFile(string name) shared
    {
        string file = buildPath(shitConfigsPath(), "styles", name ~ ".lua");
        if (!exists(file))
            throw new ExtensionRunException("extension `" ~ name ~ "`(file " ~ file ~ ") not found");

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

    override void run() shared
    {
        string[] styles = getStyles();
        foreach (style; styles)
        {
            runOneStyleFile(style);
        }
    }
}

static this()
{
    new ExtensionRunnerRegistry()
        .register!StyleExtensionRunner();
}
