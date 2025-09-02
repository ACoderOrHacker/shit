module helper.download;

import std.net.curl;

class DownloadException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

auto downloadFile(string url, string path)
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