#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-eio"

apt-get install -y libeio-dev

# Download the source
download_from_pecl eio

build_package eio
