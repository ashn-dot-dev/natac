NATAC
=====

## Dependencies (Vendored)
+ [bubby](https://github.com/ashn-dot-dev/bubby)
+ [raylib-sunder](https://github.com/ashn-dot-dev/raylib-sunder) with raylib [version 5.0](https://github.com/raysan5/raylib/releases/tag/5.0)
+ [nbnet-sunder](https://github.com/ashn-dot-dev/nbnet-sunder)
+ [smolui](https://github.com/ashn-dot-dev/smolui)
+ [sunder](https://github.com/ashn-dot-dev/sunder)

Building and linking with raylib requies some additional system dependencies to
be installed when building for Linux: https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux.

## Building

Build the native `natac` binary for Linux and macOS:

```sh
$ make build
```

## Packaging

Build the application bundle `natac.app` for macOS:

```sh
$ make package-macos
```

NOTE: After downloading `natac.app`, one will likely need to run `xattr -c
<path/to/natac.app>` to remove the `com.apple.Quarantine` extended attribute.
