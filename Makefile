.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	install \
	uninstall \
	clean

all: libsmolui.a

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

libsmolui.a:
	$(CC) $(CFLAGS) -c -I. -o microui.o microui.c
	$(CC) $(CFLAGS) -c -I. -I${SUNDER_HOME}/lib/raylib -o smolui.o smolui.c
	ar -rcs $@ microui.o smolui.o

install: libsmolui.a
	mkdir -p "$(SUNDER_HOME)/lib/smolui"
	cp microui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp smolui.sunder "$(SUNDER_HOME)/lib/smolui"
	cp libsmolui.a "$(SUNDER_HOME)/lib/smolui"

uninstall:
	rm -rf "$(SUNDER_HOME)/lib/smolui"

clean:
	rm -f \
		*.out \
		*.a \
		*.o
