NATAC
=====

A free and open source game inspired by Klaus Teuber's *Settlers of Catan*.

## Building

```sh
$ make build
```

Building and linking with raylib requies some additional system dependencies to
be installed when building for Linux: https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux.

## Packaging

Build the application bundle `natac.app` for macOS:

```sh
$ make package-macos
```

NOTE: After downloading `natac.app`, one will likely need to run `xattr -c
<path/to/natac.app>` to remove the `com.apple.Quarantine` extended attribute.
