# raylib-sunder

[Sunder](https://github.com/ashn-dot-dev/sunder) bindings for [raylib](https://github.com/raysan5/raylib).

## Dependencies
### Debian/Ubuntu

[Wiki entry](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux#ubuntu).

```sh
$ sudo apt install libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev
```

### Arch/Manjaro
[Wiki entry](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux#arch-linux).

```sh
$ sudo pacman -S alsa-lib mesa libx11 libxrandr libxi libxcursor libxinerama
```

## Build and Install
Build the `raylib.sunder` bindings as well as the `PLATFORM=PLATFORM_DESKTOP`
library (`libraylib.a`) and the `PLATFORM=PLATFORM_WEB` library
(`libraylib-web.a`):

```sh
$ make
```

Install the `raylib.sunder` bindings, `libraylib*.a` libraries, and the
`raylib-config` utility to `$(SUNDER_HOME)/lib/raylib`:

```sh
$ make install
```

## Building the Example Program (Linux)
For some C program (in this case `examples/example.c`) built with the commands:

```sh
$ cc -o example examples/example.c -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
```

the equivalent Sunder program (in this case `examples/example.sunder`) would be built with:

```sh
$ sunder-compile -o example $(${SUNDER_HOME}/lib/raylib/raylib-config desktop --libs) examples/example.sunder
```

## Building the Example Program (HTML 5)
Compiling for the web (HTML 5) requires the Emscripten toolchain
([wiki entry](https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5))).
The example shown here is built with Emscripten's
[`ASYNCIFY`](https://emscripten.org/docs/porting/asyncify.html) enabled.

```sh
$ SUNDER_ARCH=wasm32 SUNDER_HOST=emscripten SUNDER_CC=emcc SUNDER_CFLAGS="$(${SUNDER_HOME}/lib/raylib/raylib-config web --cflags) -sSINGLE_FILE=1 --shell-file emscripten-shell.html" sunder-compile -o example.html $(${SUNDER_HOME}/lib/raylib/raylib-config web --libs) examples/example.sunder
```

## Additional Notes
When developing on the Pinebook Pro (or similar platforms), raylib may fail to
initialize the OpenGL context with a `GLXBadFBConfig` error due to OpenGL 3.3+
not being supported. If this occurs, set `LIBGL_ALWAYS_SOFTWARE=true` to force
software rendering.

```sh
$ LIBGL_ALWAYS_SOFTWARE=true ./raylib-application
```

Alternatively, build with `RAYLIB_MAKEFLAGS='GRAPHICS=GRAPHICS_API_OPENGL_ES2'`
to use OpenGL ES2 for both desktop and web builds.

```sh
$ make all RAYLIB_MAKEFLAGS='GRAPHICS=GRAPHICS_API_OPENGL_ES2'
```

## License
All content in this repository is licensed under the Zero-Clause BSD license.

See LICENSE for more information.
