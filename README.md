NATAC
=====

A free and open source game inspired by Klaus Teuber's *Settlers of Catan* for
Linux and macOS.

<span float="left" align="center">
<img width="45%" src="https://github.com/ashn-dot-dev/natac/assets/60763262/e4f27eab-9218-4f52-a6f9-8dc7cc8f2605">
<img width="45%" src="https://github.com/ashn-dot-dev/natac/assets/60763262/83645b7c-fec2-496b-bd29-542a68128c5a">
</span>

## Building

### Release Build

```sh
$ make build
```

### Debug Build

```sh
$ make build CFLAGS='$(CFLAGS_DBG)' SUNDER_FLAGS='$(SUNDER_FLAGS_DBG)'
```

### Additional Notes
Building and linking with raylib requies some additional system dependencies to
be installed when building for Linux: https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux.

## Packaging

Build the application bundle `natac.app` for macOS:

```sh
$ make package-macos
```

NOTE: After downloading `natac.app`, one will likely need to run `xattr -c
<path/to/natac.app>` to remove the `com.apple.Quarantine` extended attribute.

## Running

After building the `natac` application, one may launch a Natac server with:

```sh
$ ./natac -server
```

Other players may run the game and connect to that server with:

```sh
$ ./natac -client IPADDR
```

where `IPADDR` is the IP address (IPv4) of the server.

### Example

```sh
$ ./natac -client $(dig +short natac.net)
```
