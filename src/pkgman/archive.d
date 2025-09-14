/++
 + Zip Archive Utilities
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module pkgman.archive;

public import std.zip;
import std.datetime;
import std.file;
import std.path;
import std.exception;
import std.algorithm;

/++ 
 * Zip Archive Manager, based on std.zip
 +/
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

    /++ 
     + Archive a directory to a zip file
     + Params:
     +   dirPath = The directory to archive
     +   zipFilePath = The zip file to write
     +/
    static void archiveDir(string dirPath, string zipFilePath)
    {
        if (!(exists(dirPath) && isDir(dirPath)))
            throw new FileException("directory not found: " ~ dirPath);

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

    /++ 
     + Unarchive a zip file to a directory
     + Params:
     +   zipFilePath = The zip file to read
     +   destDir = The target directory
     +/
    static void unarchive(string zipFilePath, string destDir)
    {
        if (!(exists(zipFilePath) && isFile(zipFilePath)))
            throw new FileException(
                "zip file not found: " ~ zipFilePath);

        auto archive = new ZipArchive(
            cast(ubyte[]) read(zipFilePath));
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
