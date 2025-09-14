/++
 + Downloader definations by Curl

 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module helper.download;
@safe:
export:

import std.net.curl;

/++
 + Exception thrown for downloading
 + Examples:
 + ---
 + import std.exception;
 + assertThrown!DownloadException(downloadFile("https://non-exists.com/file", "."));
 + ---
 +/
class DownloadException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

/++ 
 + Download file from the url
 + Params:
 +   url = the full url path of the file
 +   path = the traget file path
 +/
void downloadFile(in string url, in string path) @trusted
{
    try
    {
        download(url, path);
    }
    catch(CurlException e)
    {
        throw new DownloadException(e.msg);
    }
}