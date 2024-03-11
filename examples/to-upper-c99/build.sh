#!/bin/sh
set -eux

gcc -o client -std=gnu99 -I ${SUNDER_HOME}/lib/nbnet client.c shared.c -L${SUNDER_HOME}/lib/nbnet -lnbnet -lm
gcc -o server -std=gnu99 -I ${SUNDER_HOME}/lib/nbnet server.c shared.c -L${SUNDER_HOME}/lib/nbnet -lnbnet -lm
