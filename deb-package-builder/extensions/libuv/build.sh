#!/bin/bash

set -ex

echo "Downloading libuv and libuv-dev from backports"

echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
apt-get update

for PKG in `apt-get install --reinstall --print-uris -qq libuv1-dev | cut -d"'" -f2`; do
  curl -o ${ARTIFACT_DIR}/$(basename $PKG) $PKG
done
