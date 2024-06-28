#!/bin/sh
#
# Helper script that builds hsetroot as a static binary.
#
# NOTE: This script is expected to be run under Alpine Linux.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer -Wno-expansion-to-defined -Wall"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--as-needed,-O1,--sort-common --static -static -Wl,--strip-all"

export CC=xx-clang
export CXX=xx-clang++

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

function log {
    echo ">>> $*"
}

log "Installing required Alpine packages..."
apk --no-cache add \
    curl \
    build-base \
    clang \
    xz \

xx-apk --no-cache --no-scripts add \
    g++ \
    libx11-dev \
    libx11-static \
    libxcb-static \

#
# Build hsetroot.
#
log "Compiling hsetroot..."
mkdir /tmp/hsetroot
LIBS="-lX11 -lxcb -lXdmcp -lXau"
xx-clang $CFLAGS "$SCRIPT_DIR"/hsetroot.c -o /tmp/hsetroot/hsetroot $LDFLAGS -Wl,--start-group $LIBS -Wl,--end-group

log "Installing hsetroot..."
mkdir -p /tmp/hsetroot-install/usr/bin
cp -v /tmp/hsetroot/hsetroot /tmp/hsetroot-install/usr/bin/
