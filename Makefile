.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	clean

TARGET=natac

all: build

build:
	SUNDER_CFLAGS="$(SUNDER_CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --cflags)" \
	sunder-compile \
		-o $(TARGET) \
		$$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --libs) \
		-L$(SUNDER_HOME)/lib/nbnet -lnbnet \
		main.sunder

clean:
	rm -f $(TARGET) *.o *.c
