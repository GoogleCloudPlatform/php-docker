#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building lua for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-lua"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "lua extension only for PHP 7.0+"
    exit 0
fi

apt-get install -y liblua5.3-dev

for PKG in `apt-get install --reinstall --print-uris -qq liblua5.3-0 | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_PKG_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_PKG_DIR}/$(basename $PKG) $PKG
  fi
done

ln -s /usr/include/lua5.3 /usr/include/lua
ln -s /usr/lib/x86_64-linux-gnu/liblua5.3.a /usr/lib/x86_64-linux-gnu/lua.a

# Download the source
download_from_pecl lua

build_package lua
