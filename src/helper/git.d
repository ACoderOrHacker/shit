/++
 + A git helper for shit
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.git;
@safe:
export:

import std.process;
import std.path;
import std.file;
import std.array;
import std.algorithm;

import std.format;
import std.stdio;

/++ 
 * Thrown by GitData
 + See_Also: GitData
 +/
class GitException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

/++ 
 + Git data reader
 +/
class GitData
{
    private string path_;
    private string gitPath_;
    private string gitRepoPath_;

    this(string gitPath, string path, bool recursion = false)
    {
        string pathTemp = gitPathGet(path, recursion);
        if (pathTemp is null)
            throw new GitException("git repository not found: " ~ path);

        this.gitPath_ = gitPath;
        this.path_ = pathTemp;
        this.gitRepoPath_ = buildPath(pathTemp, ".git");

        if (!exists(this.gitRepoPath_))
            throw new GitException("git repository not found: " ~ this.gitRepoPath_);
    }

    /++ 
     + Get the .git directory's parent directory
     + Returns: The directory
     +/
    @property
    string path()
    {
        assert(this.path_ != null);
        return this.path_;
    }

    /++ 
     + Get the git executable path
     + Returns: The git executable path
     +/
    @property
    string gitPath()
    {
        return this.gitPath_ == null ? "git" : this.gitPath_;
    }

    /++ 
     + Get the .git directory
     + Returns: The .git directory
     +/
    @property
    string gitRepo()
    {
        return this.gitRepoPath_;
    }

    /++ 
     + Get the current branch of this git repo
     + Returns: The current branch name
     +/
    @property
    string currentBranch()
    {
        string headFile = buildPath(this.gitRepo, "HEAD");
        if (exists(headFile))
        {
            string headContent = (readText(headFile))[0 .. $ - 1];
            if (headContent.startsWith("ref: "))
            {
                string[] parts = headContent.split("/");
                return parts[$ - 1];
            }
            else
            {
                return "(detached HEAD)";
            }
        }
        else
        {
            throw new GitException("Not a git repository: " ~ this.gitRepo);
        }
    }

    private string gitPathGet(string path, bool recursion)
    {
        if (!recursion)
        {
            if (!exists(path))
                return path;
            return null;
        }

        string currentDir = absolutePath(path);
        do
        {
            string gitPath = buildPath(currentDir, ".git");

            if (exists(gitPath))
                return currentDir;

            string parentDir = dirName(currentDir);

            if (parentDir == currentDir)
                break;

            currentDir = parentDir;
        }
        while (true);

        return null;
    }
}
