module pkgman.archive;

public import std.zip;
import std.datetime;
import std.file;
import std.path;
import std.exception;
import std.algorithm;

class ArchiveManager
{
    private static void addMember(ZipArchive ar, string name, ubyte[] data)
    {
        ArchiveMember member = new ArchiveMember;
        member.name = name;
        member.expandedData(data);
        member.compressionMethod = CompressionMethod.deflate;
        member.time(Clock.currTime());

        ar.addMember(member);
    }

    static void archiveDir(string dirPath, string zipFilePath)
    {
        enforce(exists(dirPath) && isDir(dirPath), "directory not found: " ~ dirPath);

        auto archive = new ZipArchive;
        foreach (entry; dirEntries(dirPath, SpanMode.depth))
        {
            if (isFile(entry))
            {
                string prefix = dirPath ~ dirSeparator;
                string relPath = entry.name();
                if (relPath.startsWith(prefix))
                    relPath = relPath[prefix.length .. $];
                addMember(archive, relPath, cast(ubyte[]) read(entry));
            }
        }
        write(zipFilePath, archive.build());
    }

    static void unarchive(string zipFilePath, string destDir)
    {
        enforce(exists(zipFilePath) && isFile(zipFilePath), "zip file not found: " ~ zipFilePath);
        auto archive = new ZipArchive(cast(ubyte[]) read(zipFilePath));
        foreach (member; archive.directory)
        {
            archive.expand(member);
            string fullPath = buildPath(destDir, member.name);
            if (member.name.endsWith("/"))
            {
                mkdirRecurse(fullPath);
            }
            else
            {
                mkdirRecurse(dirName(fullPath));
                write(fullPath, member.expandedData);
            }
        }
    }
}
