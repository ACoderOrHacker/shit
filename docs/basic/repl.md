---
outline: deep
title: REPL
editLink: true
---

# Introduction
`Shit` provides options to run REPL in your computer, or other things.

All commands can be viewed through `shit -h` or `shit --help`. The command format is as follows:
```
shit [arguments] ...
```

## Run REPL
`shit` can be easy to run REPL environment, just `shit` or `shit --repl`.

Or you can type `chsh /usr/bin/shit` to change your default shell to `shit`.

## Packages
`shit` runs all the packages by default before the REPL mode starts.
You can change this `strategy` by run `shit -r --loading-packages=false`
Then, `shit` will not run the packages