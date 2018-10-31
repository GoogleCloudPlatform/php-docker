#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libsodium for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-libsodium"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl libsodium 1.0.7
elif [ ${SHORT_VERSION} == '72' ]; then
    echo "no need for building libsodium for gcp-php${SHORT_VERSION}"
    exit 0
else
    download_from_pecl libsodium 2.0.12
fi

build_package libsodium
