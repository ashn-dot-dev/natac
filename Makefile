.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	build-web \
	install \
	install-web \
	uninstall \
	clean

RAYLIB_DIR=raylib
RAYLIB_URL=https://github.com/raysan5/raylib.git
RAYLIB_VERSION=master
RAYLIB_MAKEFLAGS=

all: raylib.sunder raymath.sunder libraylib.a libraylib-web.a

$(RAYLIB_DIR):
	git clone --single-branch --branch "$(RAYLIB_VERSION)" "$(RAYLIB_URL)" "$(RAYLIB_DIR)"

$(RAYLIB_DIR)/parser/raylib_api.json: $(RAYLIB_DIR)
	(cd $(RAYLIB_DIR)/parser && $(MAKE) clean raylib_api.json FORMAT=JSON EXTENSION=json)

$(RAYLIB_DIR)/parser/raymath_api.json: $(RAYLIB_DIR)
	(cd $(RAYLIB_DIR)/parser && $(MAKE) clean raymath_api.json FORMAT=JSON EXTENSION=json)

raylib.sunder: $(RAYLIB_DIR)/parser/raylib_api.json generate.py
	python3 generate.py raylib $(RAYLIB_DIR)/parser/raylib_api.json >raylib.sunder

raymath.sunder: $(RAYLIB_DIR)/parser/raymath_api.json generate.py
	python3 generate.py raymath $(RAYLIB_DIR)/parser/raymath_api.json >raymath.sunder

libraylib.a: $(RAYLIB_DIR)
	(cd $(RAYLIB_DIR)/src && $(MAKE) clean && $(MAKE) PLATFORM=PLATFORM_DESKTOP $(RAYLIB_MAKEFLAGS))
	(cp $(RAYLIB_DIR)/src/libraylib.a libraylib.a)

libraylib-web.a: $(RAYLIB_DIR)
	(cd $(RAYLIB_DIR)/src && $(MAKE) clean && $(MAKE) PLATFORM=PLATFORM_WEB $(RAYLIB_MAKEFLAGS))
	(cp $(RAYLIB_DIR)/src/libraylib.a libraylib-web.a)

build: raylib.sunder raymath.sunder libraylib.a

build-web: raylib.sunder raymath.sunder libraylib-web.a

install: build
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp raymath.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIR)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIR)/src/raymath.h "$(SUNDER_HOME)/lib/raylib"
	cp raylib-config "$(SUNDER_HOME)/lib/raylib"
	cp libraylib.a "$(SUNDER_HOME)/lib/raylib"

install-web: build-web
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp raymath.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIR)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIR)/src/raymath.h "$(SUNDER_HOME)/lib/raylib"
	cp raylib-config "$(SUNDER_HOME)/lib/raylib"
	cp libraylib-web.a "$(SUNDER_HOME)/lib/raylib"
	cp emscripten-shell.html "${SUNDER_HOME}/lib/raylib"

uninstall:
	rm -rf "$(SUNDER_HOME)/lib/raylib"

clean:
	rm -f \
		raylib.sunder \
		raymath.sunder \
		libraylib.a \
		libraylib-web.a
	([ -e $(RAYLIB_DIR) ] && (cd $(RAYLIB_DIR)/src && make clean)) || true
	([ -e $(RAYLIB_DIR) ] && (cd $(RAYLIB_DIR)/parser && make clean)) || true
