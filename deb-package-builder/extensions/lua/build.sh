#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-lua"

apt-get install -y liblua5.3-dev

ln -s /usr/include/lua5.3 /usr/include/lua
ln -s /usr/lib/x86_64-linux-gnu/liblua5.3.a /usr/lib/x86_64-linux-gnu/lua.a

# Download the source
download_from_pecl lua

build_package lua
