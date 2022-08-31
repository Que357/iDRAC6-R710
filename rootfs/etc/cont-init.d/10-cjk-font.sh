#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

if [ "${ENABLE_CJK_FONT:-0}" -eq 1 ]; then
    if [ -d /usr/share/fonts/truetype/wqy ] || [ -d /usr/share/fonts/wenquanyi ]
    then
        echo "CJK font already installed."
    else
        echo "installing CJK font..."
        if [ -n "$(which apk)" ]; then
            apk add -X https://dl-cdn.alpinelinux.org/alpine/v3.16/main -u alpine-keys
            add-pkg wqy-zenhei --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing 2>&1
        else
            add-pkg fonts-wqy-zenhei 2>&1
        fi
    fi
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
