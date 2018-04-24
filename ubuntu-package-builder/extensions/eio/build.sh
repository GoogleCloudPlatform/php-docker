#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building eio for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-eio"

apt-get install -y libeio-dev

# Download the source
download_from_pecl eio

build_package eio
