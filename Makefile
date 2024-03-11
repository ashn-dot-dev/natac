.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	install \
	uninstall \
	clean

RAYLIB_REPOURL=https://github.com/raysan5/raylib.git
RAYLIB_REPODIR=raylib
RAYLIB_VERSION=master
RAYLIB_MAKEFLAGS=

all: raylib.sunder libraylib.a libraylib-web.a

$(RAYLIB_REPODIR):
	git clone --single-branch --branch "$(RAYLIB_VERSION)" "$(RAYLIB_REPOURL)" "$(RAYLIB_REPODIR)"

$(RAYLIB_REPODIR)/parser/raylib_api.json: $(RAYLIB_REPODIR)
	(cd $(RAYLIB_REPODIR)/parser && $(MAKE) clean raylib_api.json FORMAT=JSON EXTENSION=json)

raylib.sunder: $(RAYLIB_REPODIR)/parser/raylib_api.json generate.py
	python3 generate.py $(RAYLIB_REPODIR)/parser/raylib_api.json >raylib.sunder

libraylib.a: $(RAYLIB_REPODIR)
	(cd $(RAYLIB_REPODIR)/src && $(MAKE) clean all PLATFORM=PLATFORM_DESKTOP $(RAYLIB_MAKEFLAGS))
	(cp $(RAYLIB_REPODIR)/src/libraylib.a libraylib.a)

libraylib-web.a: $(RAYLIB_REPODIR)
	(cd $(RAYLIB_REPODIR)/src && $(MAKE) clean all PLATFORM=PLATFORM_WEB $(RAYLIB_MAKEFLAGS))
	(cp $(RAYLIB_REPODIR)/src/libraylib.a libraylib-web.a)

install: raylib.sunder libraylib.a
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_REPODIR)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp raylib-config "$(SUNDER_HOME)/lib/raylib"
	cp libraylib.a "$(SUNDER_HOME)/lib/raylib"

install-web: raylib.sunder libraylib-web.a
	mkdir -p "$(SUNDER_HOME)/lib/raylib"
	cp raylib.sunder "$(SUNDER_HOME)/lib/raylib"
	cp $(RAYLIB_REPODIR)/src/raylib.h "$(SUNDER_HOME)/lib/raylib"
	cp raylib-config "$(SUNDER_HOME)/lib/raylib"
	cp libraylib-web.a "$(SUNDER_HOME)/lib/raylib"
	cp emscripten-shell.html "${SUNDER_HOME}/lib/raylib"

uninstall:
	rm -rf "$(SUNDER_HOME)/lib/raylib"

clean:
	rm -f raylib.sunder libraylib.a libraylib-web.a
	(cd $(RAYLIB_REPODIR)/src && make clean)
	(cd $(RAYLIB_REPODIR)/parser && make clean)
