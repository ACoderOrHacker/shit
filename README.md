# The SHIT terminal

[![Build](https://github.com/ACoderOrHacker/shit/actions/workflows/ci.yml/badge.svg)](https://github.com/ACoderOrHacker/shit/actions/workflows/ci.yml)

A powerful and modern terminal written in [D Programming Language](https://dlang.org/).

## The name
SHIT - shell itself :)

## Installation

This project depends on:
- [DMD](https://dlang.org)
- [Xmake](https://xmake.io)
- A C compiler

```
xmake build
xmake install
```

## Usage
```
shit
```

In shit, you can use the following patterns:

- %command args... run system command (such as winver.exe, etc.)
- @command args... run registered command or built-in command (such as cd, etc.)
- command args... run registered command or system command, if the command is not registered, it will be run as system command.