---
outline: deep
title: Create Packages
editLink: true
---

# Create Packages

## Basic Create
In `shit` cli, you can run `shit --create <Package Name>` to create a default package with [zip](https://docs.fileformat.com/compression/zip/) format.
This package just includes a package.json and an empty .pkgtype.

For example:
Run `shit --create test.pkg`
We will get a package `test.pkg`
Compress it, you will get:

```sh
$ tree test/
├── package.json
└── .pkgtype
```


## Create specialize package
At the most of time, we need to get a `type` of package.
You can run `shit --create <Package Name> --type <Package Type>`

For example:
```sh
shit --create test.pkg --type style
```
You will get a style package named `test.pkg`
Compress it, you will get:

```sh
$ tree test/
├── style
│   └── main.lua
├── package.json
└── .pkgtype
```

That's it!