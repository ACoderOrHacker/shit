---
outline: deep
title: Execute Commands
editLink: true
---

# Execute Commands

Sometimes, if we need to execute commands in other shells and don't want to go into REPL mode, we can use `Execute` mode, which provides the ability to execute commands.

## Usage
Type `shit -e "<command>"` or `shit --execute "<command>"` can do that.

For example:
```sh
shit -e "echo 'Hello Shit!'"
```