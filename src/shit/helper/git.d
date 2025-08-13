module shit.helper.git;

import std.process;
import std.path;
import std.file;

import std.format;
import std.stdio;

class GitRepoNotFoundException : Exception
{
    this(string path)
    {
        super("Git repo not found at " ~ path);
    }
}

class GitData
{
    this(string gitPath, string path, bool recursion = false)
    {
        string pathTemp = gitPathGet(path, recursion);
        if (pathTemp is null)
            throw new GitRepoNotFoundException(path);

        this.gitPath_ = gitPath;
        this.path_ = pathTemp;
        this.gitRepoPath_ = buildPath(pathTemp, ".git");

        if (!exists(this.gitRepoPath_))
            throw new GitRepoNotFoundException(this.gitRepoPath_);
    }

    @property
    string path()
    {
        assert(this.path_ != null);
        return this.path_;
    }

    @property
    string gitPath()
    {
        return this.gitPath_ == null ? "git" : this.gitPath_;
    }

    @property
    string gitRepo()
    {
        return this.gitRepoPath_;
    }

    @property
    string currentBranch()
    {
        try
        {
            string fullCommand = format("%s --git-dir=%s branch --no-color", gitPath, buildPath(path, ".git"));
            auto result = executeShell(fullCommand);
            if (result.status != 0)
                return null;
            return result.output[2 .. $ - 1];
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private string path_;
    private string gitPath_;
    private string gitRepoPath_;
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
