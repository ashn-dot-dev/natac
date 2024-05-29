#!/bin/sh
#
# Run the resulting executable (Linux):
#
#   $ LD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/path/to/libdatachannel/lib" ./server
#   $ LD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/path/to/libdatachannel/lib" ./client IP
#
# Run the resulting executable (macOS):
#
#   $ DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/path/to/libdatachannel/lib" ./server
#   $ DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/path/to/libdatachannel/lib" ./client IP
set -eux

LIBDATACHANNEL_DIR="$1"
if [ -z "${LIBDATACHANNEL_DIR}" ]; then
  1>&2 echo "error: missing libdatachannel directory"
  exit 1
fi

SUNDER_CFLAGS="$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --cflags)" \
sunder-compile -o client \
    $(${SUNDER_HOME}/lib/raylib/raylib-config desktop --libs) \
    -L${SUNDER_HOME}/lib/nbnet -lnbnet \
    -L${LIBDATACHANNEL_DIR}/lib -ldatachannel \
    client.sunder

sunder-compile -o server \
    -L${SUNDER_HOME}/lib/nbnet -lnbnet \
    -L${LIBDATACHANNEL_DIR}/lib -ldatachannel \
    server.sunder
