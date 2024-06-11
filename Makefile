.POSIX:
.SUFFIXES:
.PHONY: \
	all \
	build \
	clean \
	fresh \
	package-macos

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

SUNDER_FLAGS_DBG=-g -k
SUNDER_FLAGS_REL=
SUNDER_FLAGS=$(SUNDER_FLAGS_REL)

SUNDER_HOME := $$(pwd)/.sunder

all: $(TARGET)
build: $(TARGET)
package-macos: $(TARGET).app $(TARGET).app.zip

$(TARGET): \
	.sunder \
	.sunder/lib/bubby \
	.sunder/lib/nbnet \
	.sunder/lib/raylib \
	.sunder/lib/smolui \
	util.c shared.sunder server.sunder client.sunder main.sunder
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	SUNDER_CC=clang \
	SUNDER_CFLAGS="$(CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop)" \
	sunder-compile \
		$(SUNDER_FLAGS) \
		-o $(TARGET) \
		-L$(SUNDER_HOME)/lib/nbnet -lnbnet \
		-L$(SUNDER_HOME)/lib/smolui -lsmolui \
		util.c \
		main.sunder

.sunder:
	SUNDER_HOME=$(SUNDER_HOME); CC=clang CFLAGS='$$(GNU_REL)' \
	$(MAKE) -e -C vendor/sunder install

.sunder/lib/bubby: .sunder
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	$(MAKE) -e -C vendor/bubby install

.sunder/lib/nbnet: .sunder
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	NBNET_DIR=$$(realpath vendor/nbnet) \
	$(MAKE) -e -C vendor/nbnet-sunder install

.sunder/lib/raylib: .sunder
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	RAYLIB_DIR=$$(realpath vendor/raylib) \
	$(MAKE) -e -C vendor/raylib-sunder install

.sunder/lib/smolui: .sunder
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	$(MAKE) -e -C vendor/smolui install

$(TARGET).app: $(TARGET) macos/Natac.icns
	mkdir -p $(TARGET).app/Contents
	mkdir -p $(TARGET).app/Contents/MacOS
	mkdir -p $(TARGET).app/Contents/Resources
	cp macos/Info.plist natac.app/Contents/Info.plist
	cp $(TARGET) $(TARGET).app/Contents/MacOS/$(TARGET)
	cp macos/Natac.icns natac.app/Contents/Resources/Natac.icns

$(TARGET).app.zip: $(TARGET).app
	zip -vr $(TARGET).app.zip $(TARGET).app

macos/Natac.icns: macos/Natac.png
	mkdir macos/Natac.iconset
	sips -z 16 16   macos/Natac.png --out macos/Natac.iconset/icon_16x16.png
	sips -z 32 32   macos/Natac.png --out macos/Natac.iconset/icon_16x16@2x.png
	sips -z 32 32   macos/Natac.png --out macos/Natac.iconset/icon_32x32.png
	sips -z 64 64   macos/Natac.png --out macos/Natac.iconset/icon_32x32@2x.png
	sips -z 128 128 macos/Natac.png --out macos/Natac.iconset/icon_128x128.png
	sips -z 256 256 macos/Natac.png --out macos/Natac.iconset/icon_128x128@2x.png
	sips -z 256 256 macos/Natac.png --out macos/Natac.iconset/icon_256x256.png
	sips -z 512 512 macos/Natac.png --out macos/Natac.iconset/icon_256x256@2x.png
	sips -z 512 512 macos/Natac.png --out macos/Natac.iconset/icon_512x512.png
	cp macos/Natac.png macos/Natac.iconset/icon_512
	iconutil --convert icns macos/Natac.iconset -o macos/Natac.icns

macos/Natac.png: macos/icon.sunder .sunder/lib/raylib
	SUNDER_HOME=$(SUNDER_HOME); . $(SUNDER_HOME)/env; \
	SUNDER_CC=clang \
	SUNDER_CFLAGS="$(CFLAGS) $$($(SUNDER_HOME)/lib/raylib/raylib-config desktop)" \
	sunder-compile \
		-o macos/icon.out \
		macos/icon.sunder
	cd macos && ./icon.out

clean:
	rm -rf \
		$(TARGET) \
		$(TARGET).app \
		$(TARGET).app.zip \
		macos/Natac.* \
		$(SUNDER_HOME) \
		$$(find . -name '*.out') \
		$$(find . -name '*.tmp.*')

fresh:
	git clean -dfx
