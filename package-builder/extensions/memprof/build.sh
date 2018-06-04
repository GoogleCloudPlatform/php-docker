#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building memprof for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memprof"

apt-get install -y gawk libjudy-dev

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memprof 1.0.0
else
    download_from_pecl memprof
fi

build_package memprof
