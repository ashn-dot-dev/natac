#!/bin/sh

set -e
set -x
VERSION=alpha-$(date -u +"%Y.%m.%d")
git tag -a "${VERSION}" -m "Release ${VERSION}"
