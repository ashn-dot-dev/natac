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

RAYLIB_DIRECTORY=RAYLIB
RAYLIB_MAKEFLAGS=

all: raylib.sunder raymath.sunder libraylib.a libraylib-web.a

raylib_api.json: $(RAYLIB_DIRECTORY)
	(cd $(RAYLIB_DIRECTORY)/parser && $(MAKE) clean raylib_api.json FORMAT=JSON EXTENSION=json)
	cp $(RAYLIB_DIRECTORY)/parser/raylib_api.json $@

raymath_api.json: $(RAYLIB_DIRECTORY)
	(cd $(RAYLIB_DIRECTORY)/parser && $(MAKE) clean raymath_api.json FORMAT=JSON EXTENSION=json)
	cp $(RAYLIB_DIRECTORY)/parser/raymath_api.json $@

raylib.sunder: raylib_api.json generate.py
	python3 generate.py raylib raylib_api.json >raylib.sunder

raymath.sunder: raymath_api.json generate.py
	python3 generate.py raymath raymath_api.json >raymath.sunder

libraylib.a: $(RAYLIB_DIRECTORY)
	(cd $(RAYLIB_DIRECTORY)/src && $(MAKE) clean && $(MAKE) PLATFORM=PLATFORM_DESKTOP $(RAYLIB_MAKEFLAGS))
	cp $(RAYLIB_DIRECTORY)/src/libraylib.a $@

libraylib-web.a: $(RAYLIB_DIRECTORY)
	(cd $(RAYLIB_DIRECTORY)/src && $(MAKE) clean && $(MAKE) PLATFORM=PLATFORM_WEB $(RAYLIB_MAKEFLAGS))
	cp $(RAYLIB_DIRECTORY)/src/libraylib.a $@

build: raylib.sunder raymath.sunder libraylib.a

build-web: raylib.sunder raymath.sunder libraylib-web.a

install: build
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp raymath.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIRECTORY)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIRECTORY)/src/raymath.h "$(SUNDER_HOME)/lib/raylib"
	cp raylib-config "$(SUNDER_HOME)/lib/raylib"
	cp libraylib.a "$(SUNDER_HOME)/lib/raylib"

install-web: build-web
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp raymath.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIRECTORY)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_DIRECTORY)/src/raymath.h "$(SUNDER_HOME)/lib/raylib"
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
		libraylib-web.a \
		*.json
	(if [ -e $(RAYLIB_DIRECTORY) ]; then (cd $(RAYLIB_DIRECTORY)/src && make -i clean); fi)
	(if [ -e $(RAYLIB_DIRECTORY) ]; then (cd $(RAYLIB_DIRECTORY)/parser && make -i clean); fi)
