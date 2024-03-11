#!/bin/sh
set -eux

SUNDER_CFLAGS="$(${SUNDER_HOME}/lib/raylib/raylib-config desktop --cflags)" \
sunder-compile -o client \
    $(${SUNDER_HOME}/lib/raylib/raylib-config desktop --libs) \
    -L${SUNDER_HOME}/lib/nbnet -lnbnet \
    client.sunder

sunder-compile -o server \
    -L${SUNDER_HOME}/lib/nbnet -lnbnet \
    server.sunder
