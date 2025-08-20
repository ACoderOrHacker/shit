module pkgman.configs;

import std.path;
import std.conv;
import shit.configs.basic;
import shit.configs.project;

export class PkgmanConfigNotFoundException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class BadPkgmanConfigException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

@property
export string packagesPath()
{
    return buildPath(shitConfigsPath(), "packages");
}

export struct PkgmanConfig
{
    string[] enablePackages;
}

export PkgmanConfig readPkgmanConfig()
{
    PkgmanConfig config;
    JSONValue root;
    try
    {
        root = readJSON(buildPath(packagesPath, "settings.json"));
    }
    catch (Exception e)
    {
        throw new PkgmanConfigNotFoundException(
            "Unable to read pkgman configuration file (packages/settings.json): " ~ e.msg);
    }

    try
    {
        JSONValue jEnabled = root["enabled-packages"];
        if (jEnabled.type == JSONType.array)
        {
            JSONValue[] values = jEnabled.get!(JSONValue[]);

            config.enablePackages.length = values.length;
            foreach (i, value; values)
            {
                if (value.type != JSONType.string)
                    throw new BadPkgmanConfigException(
                        "at packages/settings.json:index `" ~ i.to!string ~ "`, not a string value");
                config.enablePackages[i] = value.get!string;
            }
        }
        else
        {
            throw new BadPkgmanConfigException("enabled-packages is not an array");
        }
    }
    catch (JSONException e)
    {
        throw new PkgmanConfigNotFoundException(
            "Unable to read enabled-packages from packages/settings.json configuration file");
    }

    return config;
}

export void writePkgmanConfig(PkgmanConfig config)
{
    JSONValue root = JSONValue.emptyObject;
    try
    {
        JSONValue[] packages;
        packages.length = config.enablePackages.length;
        foreach (i, value; config.enablePackages)
        {
            packages[i] = value;
        }

        root.object["enabled-packages"] = packages;

        writeJSON(buildPath(packagesPath, "settings.json"), root, true);
    }
    catch (JSONException e)
    {
        throw new PkgmanConfigNotFoundException(
            "Unable to read enabled-packages from packages/settings.json configuration file");
    }
}
