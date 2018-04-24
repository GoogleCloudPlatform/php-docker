#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building lua for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-lua"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "lua extension only for PHP 7.0+"
    exit 0
fi

ln -sf /usr/include/lua5.3 /usr/include/lua
ln -sf /usr/lib/x86_64-linux-gnu/liblua5.3.a /usr/lib/x86_64-linux-gnu/lua.a

# Download the source
download_from_pecl lua

build_package lua
