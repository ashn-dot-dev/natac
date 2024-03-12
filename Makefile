.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	clean

TARGET=natac

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

SUNDER_HOME := $$(pwd)/.sunder

all: build

build: .sunder .sunder/lib/bubby .sunder/lib/nbnet .sunder/lib/raylib .sunder/lib/smolui
	SUNDER_HOME=$(SUNDER_HOME) \
	SUNDER_SEARCH_PATH=$(SUNDER_HOME)/lib \
	SUNDER_CC=clang \
	SUNDER_CFLAGS="$(CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --cflags)" \
	.sunder/bin/sunder-compile \
		-o $(TARGET) \
		$$($(SUNDER_HOME)/lib/raylib/raylib-config desktop --libs) \
		-L$(SUNDER_HOME)/lib/nbnet -lnbnet \
		-L$(SUNDER_HOME)/lib/smolui -lsmolui \
		main.sunder

.sunder:
	SUNDER_HOME=$(SUNDER_HOME) \
	$(MAKE) -e -C vendor/sunder install

.sunder/lib/bubby: .sunder
	SUNDER_HOME=$(SUNDER_HOME) \
	$(MAKE) -e -C vendor/bubby install

.sunder/lib/nbnet: .sunder
	SUNDER_HOME=$(SUNDER_HOME) \
	NBNET_REPODIR=$$(realpath vendor/nbnet) \
	$(MAKE) -e -C vendor/nbnet-sunder install

.sunder/lib/raylib: .sunder
	SUNDER_HOME=$(SUNDER_HOME) \
	RAYLIB_REPODIR=$$(realpath vendor/raylib) \
	$(MAKE) -e -C vendor/raylib-sunder install

.sunder/lib/smolui: .sunder
	SUNDER_HOME=$(SUNDER_HOME) \
	$(MAKE) -e -C vendor/smolui install

clean:
	rm -f $(TARGET) *.tmp.o *.tmp.c
	rm -rf $(SUNDER_HOME)
