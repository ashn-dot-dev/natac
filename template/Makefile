.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	build-web \
	clean

TARGET=game

all: build build-web

build:
	SUNDER_CFLAGS="$(SUNDER_CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop)" \
	sunder-compile -o $(TARGET) main.sunder

build-web:
	SUNDER_ARCH=wasm32 \
	SUNDER_HOST=emscripten \
	SUNDER_CC=emcc \
	SUNDER_CFLAGS="$(SUNDER_CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config web) -sSINGLE_FILE=1 --shell-file $(SUNDER_HOME)/lib/raylib/emscripten-shell.html" \
	sunder-compile -o $(TARGET).html main.sunder

clean:
	rm -f $(TARGET) $(TARGET).html *.tmp.*
