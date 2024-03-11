#!/bin/sh
set -eux

sunder-compile -o client -L${SUNDER_HOME}/lib/nbnet -lnbnet client.sunder
sunder-compile -o server -L${SUNDER_HOME}/lib/nbnet -lnbnet server.sunder
