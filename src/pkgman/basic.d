module pkgman.basic;

import std.zip;
import std.file;
import std.json;
import std.conv;
import std.datetime;

class BadPackageFileException : Exception {
    this(string msg) {
        super(msg);
    }
}

class BadPackageException : Exception {
    this(string msg) {
        super(msg);
    }
}

class BadPackageInfoException : Exception {
    this(string msg) {
        super(msg);
    }
}

class PackageInfo {
    string type;
    
    string name;
    string ver;
    string desc;

    string[] authors;
    string license;
}

class Package(string Pkgtype) {
    protected void readExtra(ZipArchive, ArchiveMember, string, ref PackageInfo) {}
    protected void writeExtra(ZipArchive, PackageInfo) {}
    protected PackageInfo defaultPackage() {
        PackageInfo info = new PackageInfo;

        info.type = Pkgtype;
        info.name = "";
        info.ver = "";
        info.desc = "";
        info.license = "";
        info.authors = [];

        return info;
    }

    final this(string file) {
        this.file_ = file;
    }

    protected auto getFile() {
        return file_;
    }

    PackageInfo readPackage() {
        static T readValue(T)(JSONValue jsonValue, string key) {
            try {
                return jsonValue[key].get!T;
            } catch (JSONException e) {
                throw new BadPackageInfoException(e.msg);
            }
        }

        ZipArchive archive = null;
        try {
            archive = new ZipArchive(read(file_));
        } catch (ZipException e) {
            throw new BadPackageException(e.msg);
        } catch (FileException e) {
            throw new BadPackageFileException(e.msg);
        }

        PackageInfo info = new PackageInfo;
        foreach (name, am; archive.directory) {
            archive.expand(am);
            if (name == ".pkgtype") {
                if (am.expandedSize <= 0)
                    throw new BadPackageInfoException("bad .pkgtype file, length <= 0");
                info.type = cast(string)am.expandedData;
            } else if (name == "package.json") {
                try {
                    auto jsonValue = parseJSON(cast(string)am.expandedData);

                    info.name    = readValue!string(jsonValue, "name");
                    info.ver     = readValue!string(jsonValue, "version");
                    info.desc    = readValue!string(jsonValue, "description");
                    info.license = readValue!string(jsonValue, "license");
                    auto authorsValue = readValue!(JSONValue[])(jsonValue, "authors");
                    info.authors.length = authorsValue.length;
                    foreach (index, authorValue; authorsValue) {
                        try {
                            info.authors[index] = authorValue.str;
                        } catch (JSONException e) {
                            throw new BadPackageInfoException(
                                "from package.json/authors[" ~ index.to!string ~ "]: " ~ e.msg);
                        }
                    }
                } catch (JSONException e) {
                    throw new BadPackageInfoException(e.msg);
                }
            }

            readExtra(archive, am, name, info);
        }

        return info;
    }

    void writePackage(PackageInfo info) {
        ZipArchive archive = new ZipArchive;

        ArchiveMember pkgtypeFile = new ArchiveMember;
        pkgtypeFile.name = ".pkgtype";
        pkgtypeFile.expandedData(cast(ubyte[])info.type);
        pkgtypeFile.compressionMethod = CompressionMethod.deflate;
        pkgtypeFile.time(Clock.currTime());

        ArchiveMember packageJsonFile = new ArchiveMember;
        JSONValue packageValue = [
            "name":        JSONValue(info.name),
            "version":     JSONValue(info.ver),
            "description": JSONValue(info.desc),
            "license":     JSONValue(info.license),
            "authors":     JSONValue(info.authors)
        ];

        packageJsonFile.name = "package.json";
        packageJsonFile.expandedData(cast(ubyte[])packageValue.toPrettyString);
        packageJsonFile.compressionMethod = CompressionMethod.deflate;
        pkgtypeFile.time(Clock.currTime());

        archive.addMember(pkgtypeFile);
        archive.addMember(packageJsonFile);

        writeExtra(archive, info);
        auto data = archive.build();
        write(file_, data);
    }

    void writeDefaultPackage() {
        writePackage(defaultPackage());
    }

    private string file_;
}