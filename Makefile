.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	clean

TARGET=natac

all: build

# NOTE: Compiling with -O0 and -O1 on ARM64 macOS will produce a binary that
# causes a stack overflow when run, presumably due to large stack frame size.
# Bumping up the stack size to 16 MB with:
#
#   -O0 -Wl,-stack_size -Wl,0x1000000
#
# or compiling with optimizations using:
#
#   -Os
#
# is enough to fix the issue.
CFLAGS_DBG=-O0 -Wl,-stack_size -Wl,0x1000000 -g
CFLAGS_REL=-Os
CFLAGS=$(CFLAGS_REL)

build:
	SUNDER_CC=clang \
	SUNDER_CFLAGS="$(CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --cflags)" \
	sunder-compile \
		-o $(TARGET) \
		$$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --libs) \
		-L$(SUNDER_HOME)/lib/nbnet -lnbnet \
		-L$(SUNDER_HOME)/lib/smolui -lsmolui \
		main.sunder

clean:
	rm -f $(TARGET) *.o *.c
