module shit.helper.git;

import std.process;
import std.path;
import std.file;

import std.format;
import std.stdio;

class GitRepoNotFoundException : Exception {
    this(string path) {
        super("Git repo not found at " ~ path);
    }
}

class GitData {
    this(string gitPath, string path) {
        this.gitPath_ = gitPath;
        this.path_ = path;
        this.gitRepoPath_ = buildPath(path, ".git");

        if (!exists(this.gitRepoPath_))
            throw new GitRepoNotFoundException(path);
    }

    @property
    string path() {
        assert(this.path_ != null);
        return this.path_;
    }

    @property
    string gitPath() {
        return this.gitPath_ == null ? "git" : this.gitPath_;
    }

    @property
    string gitRepo() {
        return this.gitRepoPath_;
    }

    @property
    string currentBranch() {
        scope(failure) return null;
        string fullCommand = format("%s --git-dir=%s branch --no-color", gitPath, buildPath(path, ".git"));
        auto result = executeShell(fullCommand);
        if (result.status != 0) return null;
        return result.output[2 .. $ - 1];
    }

    private string path_;
    private string gitPath_;
    private string gitRepoPath_;
}