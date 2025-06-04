# raylib-sunder

[Sunder](https://github.com/ashn-dot-dev/sunder) bindings for [raylib](https://www.raylib.com).

## Build and Install
Clone the [raylib repository](https://github.com/raysan5/raylib) into the
directory of your choice (in this case `~/sources/raylib`), and checkout the
release version that you would like to build and install bindings for:

```sh
git clone https://github.com/raysan5/raylib.git ~/sources/raylib
(cd ~/sources/raylib && git checkout 5.5)
```

Set `RAYLIB_DIRECTORY=/your/path/to/raylib` and run `make build build-web` to
generate the `raylib.sunder` and `raymath.sunder` bindings as well as build the
`PLATFORM=PLATFORM_DESKTOP` library (`libraylib.a`) and the
`PLATFORM=PLATFORM_WEB` library (`libraylib-web.a`):

```sh
make RAYLIB_DIRECTORY=~/sources/raylib build build-web
```

Install the raylib sunder bindings, raylib libraries, and the `raylib-config`
utility to `$SUNDER_HOME/lib/raylib`:

```sh
make RAYLIB_DIRECTORY=~/sources/raylib install install-web
```

## Building the Example Program (Desktop)
```sh
SUNDER_CFLAGS="$(${SUNDER_HOME}/lib/raylib/raylib-config desktop)" sunder-compile -o example examples/example.sunder
```

## Building the Example Program (HTML 5)
Compiling for the web (HTML 5) requires the Emscripten toolchain
([wiki entry](https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5))).

```sh
SUNDER_ARCH=wasm32 SUNDER_HOST=emscripten SUNDER_CC=emcc SUNDER_CFLAGS="$(${SUNDER_HOME}/lib/raylib/raylib-config web) -sSINGLE_FILE=1 --shell-file emscripten-shell.html" sunder-compile -o example.html examples/example.sunder
```

## Additional Notes
When developing on the Pinebook Pro (or similar platforms), raylib may fail to
initialize the OpenGL context with a `GLXBadFBConfig` error due to OpenGL 3.3+
not being supported. If this occurs, set `LIBGL_ALWAYS_SOFTWARE=true` to force
software rendering.

```sh
LIBGL_ALWAYS_SOFTWARE=true ./raylib-application
```

Alternatively, build with `RAYLIB_MAKEFLAGS='GRAPHICS=GRAPHICS_API_OPENGL_ES2'`
to use OpenGL ES2 for both desktop and web builds.

```sh
make RAYLIB_DIRECTORY=/your/path/to/raylib RAYLIB_MAKEFLAGS='GRAPHICS=GRAPHICS_API_OPENGL_ES2' all
```

## License
All content in this repository is licensed under the Zero-Clause BSD license.

See LICENSE for more information.
