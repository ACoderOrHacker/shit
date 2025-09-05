module pkgman.configs;
@safe:
export:

import std.path;
import std.conv;
import shit.configs.basic;
import shit.configs.jsonconfigdef;

private enum pkgconfigFileAbsPath
    = buildPath("packages", "settings.json");

struct PkgmanConfig
{
    string[] enabledPackages;
}

alias pkgconfig = JSONConfig!(PkgmanConfig, pkgconfigFileAbsPath);

string packagesPath()
{
    return buildPath(pkgconfig.baseDir, "packages");
}