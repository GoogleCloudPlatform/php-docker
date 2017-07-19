#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memprof"

apt-get install -y gawk libjudy-dev

# Download the source
download_from_pecl memprof

build_package memprof
