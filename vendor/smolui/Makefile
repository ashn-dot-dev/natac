.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	demos \
	install \
	install-web
	uninstall \
	clean

all: libsmolui.a
demos: demo.c.out demo.sunder.out demo.sunder.html

demo.c.out: libsmolui.a
	$(CC) $(CFLAGS) -o $@ demo.c \
		-I. -L. \
		-I${SUNDER_HOME}/lib/raylib \
		$$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --cflags) \
		$$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --libs) \
		-lsmolui

demo.sunder.out: demo.sunder smolui.sunder microui.sunder libsmolui.a
	SUNDER_CFLAGS="$(CFLAGS) $$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --cflags)" \
	sunder-compile -o $@ \
		$$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --libs) \
		-L. -lsmolui \
		demo.sunder

# NOTE: We compile web builds with a stack size of 2^22 as microui/smolui uses
# a *lot* of stack space. With default CFLAGS, the microui web demo will fail
# to load in both Firefox and Chrome. This issue can be somewhat mitigated by
# providing the -Os optimization flags as part of the user-defined CFLAGS.
demo.sunder.html: demo.sunder smolui.sunder microui.sunder libsmolui-web.a
	SUNDER_ARCH=wasm32 \
	SUNDER_HOST=emscripten \
	SUNDER_CC=emcc \
	SUNDER_CFLAGS="$(CFLAGS) $$(${SUNDER_HOME}/lib/raylib/raylib-config web --cflags) -sSTACK_SIZE=$$(echo '2^22' | bc) -sSINGLE_FILE=1 --shell-file $(SUNDER_HOME)/lib/raylib/emscripten-shell.html" \
	sunder-compile -o $@ \
		$$(${SUNDER_HOME}/lib/raylib/raylib-config web --libs) \
		-L. -lsmolui-web \
		demo.sunder

libsmolui.a:
	$(CC) $(CFLAGS) -c -I. -o microui.o microui.c
	$(CC) $(CFLAGS) -c -I. -I${SUNDER_HOME}/lib/raylib -o smolui.o smolui.c
	ar -rcs $@ microui.o smolui.o

libsmolui-web.a:
	emcc $(CFLAGS) -c -I. -o microui-web.o microui.c
	emcc $(CFLAGS) -c -I. -I${SUNDER_HOME}/lib/raylib -o smolui-web.o smolui.c
	emar -rcs $@ microui-web.o smolui-web.o

install: libsmolui.a
	mkdir -p "$(SUNDER_HOME)/lib/smolui"
	cp microui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp smolui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp libsmolui.a "$(SUNDER_HOME)/lib/smolui"

install-web: libsmolui-web.a
	mkdir -p "$(SUNDER_HOME)/lib/smolui"
	cp microui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp smolui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp libsmolui-web.a "$(SUNDER_HOME)/lib/smolui"

uninstall:
	rm -rf "$(SUNDER_HOME)/lib/smolui"

clean:
	rm -f \
		*.html \
		*.out \
		*.a \
		*.o
