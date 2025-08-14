module shit;

version (Windows)
{
    import core.sys.windows.dll;

    mixin SimpleDllMain;
}
