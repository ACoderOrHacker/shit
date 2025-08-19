module pkgman.basic;

import std.datetime;
import std.file;
import std.path;
import std.json;
import std.conv;
import shit.configs.project;
public import shit.configs.global;
import pkgman.configs;
public import pkgman.archive;

export class BadPackageFileException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class BadPackageException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class BadPackageInfoException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class PackageInstallException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class ExtensionRunException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

export class PackageInfo
{
    string type;

    string name;
    string ver;
    string desc;

    string[] authors;
    string license;
}

export class Package
{
    protected void addMember(T)(ZipArchive ar, string name, T data)
    {
        ArchiveMember member = new ArchiveMember;
        member.name = name;
        member.expandedData(cast(ubyte[]) data);
        member.compressionMethod = CompressionMethod.deflate;
        member.time(Clock.currTime());

        ar.addMember(member);
    }

    protected PackageInfo createPackageInfo()
    {
        return new PackageInfo;
    }

    protected void readExtra(ZipArchive, ArchiveMember, string, ref PackageInfo)
    {
    }

    protected void writeExtra(ZipArchive, PackageInfo)
    {
    }

    protected PackageInfo defaultPackage(string pkgtype)
    {
        PackageInfo info = createPackageInfo();

        info.type = pkgtype;
        info.name = "";
        info.ver = "";
        info.desc = "";
        info.license = "";
        info.authors = [];

        return info;
    }

    final this(string file)
    {
        this.file_ = file;
    }

    @property
    string file()
    {
        return file_;
    }

    PackageInfo readPackage()
    {
        static T readValue(T)(JSONValue jsonValue, string key)
        {
            try
            {
                return jsonValue[key].get!T;
            }
            catch (JSONException e)
            {
                throw new BadPackageInfoException(e.msg);
            }
        }

        ZipArchive archive = null;
        try
        {
            archive = new ZipArchive(read(file_));
        }
        catch (ZipException e)
        {
            throw new BadPackageException(e.msg);
        }
        catch (FileException e)
        {
            throw new BadPackageFileException(e.msg);
        }

        PackageInfo info = createPackageInfo();
        foreach (name, am; archive.directory)
        {
            archive.expand(am);
            if (name == ".pkgtype")
            {
                if (am.expandedSize <= 0)
                    throw new BadPackageInfoException("bad .pkgtype file, length <= 0");
                info.type = cast(string) am.expandedData;
            }
            else if (name == "package.json")
            {
                try
                {
                    auto jsonValue = parseJSON(cast(string) am.expandedData);

                    info.name = readValue!string(jsonValue, "name");
                    info.ver = readValue!string(jsonValue, "version");
                    info.desc = readValue!string(jsonValue, "description");
                    info.license = readValue!string(jsonValue, "license");
                    auto authorsValue = readValue!(JSONValue[])(jsonValue, "authors");
                    info.authors.length = authorsValue.length;
                    foreach (index, authorValue; authorsValue)
                    {
                        try
                        {
                            info.authors[index] = authorValue.str;
                        }
                        catch (JSONException e)
                        {
                            throw new BadPackageInfoException(
                                "from package.json/authors[" ~ index.to!string ~ "]: " ~ e.msg);
                        }
                    }
                }
                catch (JSONException e)
                {
                    throw new BadPackageInfoException(e.msg);
                }
            }

            readExtra(archive, am, name, info);
        }

        return info;
    }

    void writePackage(PackageInfo info)
    {
        ZipArchive archive = new ZipArchive;

        this.addMember(archive, ".pkgtype", info.type);

        JSONValue packageValue = [
            "name": JSONValue(info.name),
            "version": JSONValue(info.ver),
            "description": JSONValue(info.desc),
            "license": JSONValue(info.license),
            "authors": JSONValue(info.authors)
        ];

        this.addMember(archive, "package.json", packageValue.toPrettyString);

        writeExtra(archive, info);
        auto data = archive.build();
        write(file_, data);
    }

    void install()
    {
        ArchiveManager.unarchive(file_, extensionPath);
    }

    void uninstall()
    {
        rmdirRecurse(extensionPath);
    }

    void writeDefaultPackage(string pkgtype)
    {
        writePackage(defaultPackage(pkgtype));
    }

    @property
    string extensionPath()
    {
        return buildPath(packagesPath, baseName(file_, extension(file_)));
    }

    private string file_;
}

interface ExtensionRunner
{
    void run(string /* package name */ ,
        string /* package path */ ,
        ref GlobalConfig) shared;

    void destroy(string /* package name */ ,
        string /* package path */ ,
        ref GlobalConfig) shared;
}

/// Runner API
alias Runners = ExtensionRunner[string];

shared(Runners) runners;

export ref shared(Runners) getRunners()
{
    return runners;
}

export class ExtensionRunnerRegistry
{
    ExtensionRunnerRegistry register(Runner)(string name)
    {
        ref shared(Runners) runners_ = getRunners();
        runners_[name] = new Runner;

        return this;
    }
}
