## Lua API

### This directory is genrated by [dstep](https://github.com/jacob-carlborg/dstep)

#### How to genrate
- Download from [Releases](https://github.com/jacob-carlborg/dstep/releases/latest)
- Dowload [Conda](https://www.anaconda.com)
- Run
  ```
  conda install conda-forge::libclang
  ```
- Move libclang files to a place that dstep can see it
- Run
  ```
  dstep lua.h lauxlib.h luaconf.h -o lua
  ```
- Replace void*.sizeof to (void*).sizeof
- Then, Done!