#!/bin/sh
#
# Helper script that builds JWM as a static binary.
#
# NOTE: This script is expected to be run under Alpine Linux.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Define software versions.
JWM_VERSION=2.4.0
PANGO_VERSION=1.49.3

# Define software download URLs.
JWM_URL=https://github.com/joewing/jwm/releases/download/v${JWM_VERSION}/jwm-${JWM_VERSION}.tar.xz
PANGO_URL=https://download.gnome.org/sources/pango/${PANGO_VERSION%.*}/pango-${PANGO_VERSION}.tar.xz

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--as-needed --static -static -Wl,--strip-all -Wl,--start-group -lX11 -lxcb -lXdmcp -lXau -lfontconfig -lfreetype -lpng -lXrender -lexpat -lz -lbz2 -luuid -lbrotlidec -lbrotlicommon -lXmu -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lintl -lfribidi -lharfbuzz -lpangoxft-1.0 -lpangoft2-1.0 -lpango-1.0 -lgraphite2 -lpcre -lffi -Wl,--end-group"

export CC=xx-clang
export CXX=xx-clang++

function log {
    echo ">>> $*"
}

#
# Install required packages.
#
log "Installing required Alpine packages..."
apk --no-cache add \
    curl \
    build-base \
    clang \
    meson \
    cmake \

xx-apk --no-cache --no-scripts add \
    glib-dev \
    fribidi-dev \
    fribidi-static \
    harfbuzz-dev \
    harfbuzz-static \
    cairo-dev \
    cairo-static \
    glib-static \
    gettext-static \
    graphite2-static \
    pcre-dev \
    libffi-dev \
    libx11-dev \
    libx11-static \
    libxcb-static \
    libxdmcp-dev \
    libxau-dev \
    libxft-dev \
    libxext-dev \
    libxft-dev \
    libxmu-dev \
    libxrender-dev \
    fontconfig-static \
    freetype-static \
    expat-static \
    libjpeg-turbo-dev \
    libjpeg-turbo-static \
    libpng-dev \
    libpng-static \
    zlib-static \
    bzip2-static \
    util-linux-dev \
    brotli-static \

#
# Build pango.
# The static library is not provided by Alpine repository, so we need to build
# it ourself.
#
mkdir /tmp/pango
log "Downloading pango..."
curl -# -L ${PANGO_URL} | tar -xJ --strip 1 -C /tmp/pango

log "Configuring pango..."
(
    cd /tmp/pango && LDFLAGS= abuild-meson \
        -Ddefault_library=static \
        -Dintrospection=disabled \
        -Dgtk_doc=false \
        build \
)

log "Compiling pango..."
meson compile -C /tmp/pango/build

log "Installing pango..."
meson install --no-rebuild -C /tmp/pango/build

#
# Build JWM.
#
mkdir /tmp/jwm
log "Downloading JWM..."
curl -# -L ${JWM_URL} | tar -xJ --strip 1 -C /tmp/jwm

log "Configuring JWM..."
(
    cd /tmp/jwm && LIBS="$LDFLAGS" ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-debug \
        --disable-xpm \
        --disable-xbm \
        --disable-rsvg \
        --disable-png \
        --disable-jpeg \
        --disable-xinerama \
        --disable-confirm \
        --disable-nls \
        --enable-pango \
        --enable-cairo \
        --enable-icons \
        --enable-xrender \
        --enable-shape \
        --enable-xmu \
        --enable-xft \
)

log "Compiling JWM..."
make -C /tmp/jwm -j$(nproc)

log "Installing JWM..."
make DESTDIR=/tmp/jwm-install -C /tmp/jwm install

