---
outline: deep
title: Package Management in CLI
editLink: true
---

# Package Management in CLI

`Shit`'s package management is `powerful`.
You can install/uninstall external package easily by `shit` cli

:::tip NOTE
`Shit`'s package always ends with `.pkg`
:::

## Install the specified package
```sh
shit --install <Package Path>
```

`<Package Path>` is the package's path.

Then the package will be installed in `etc/shit/packages/<Package Name>`

## Uninstall the specified package
```sh
shit --uninstall <Package Path>
```

As same as `install`, `<Package Path>` is the package's path.

Then the package will be uninstalled from `etc/shit/packages/<Package Name>`

## Enable the specified package
An installed package needs to `enable`, or the package will not run.
```sh
shit --enable <Package Name>
```

`<Package Name>` is the name of the package (for example: `test` but not `test.pkg`)

Then the package will be enabled in packages/settings.json

## Disable the specified package
Of course, you can `disable` a package easily.
```sh
shit --disable <Package Name>
```

`<Package Name>` is same as `--enable` option

Then the package will be disabled in packages/settings.json