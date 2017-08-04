#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libsodium for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-libsodium"

install_last_package "libsodium18"
install_last_package "libsodium-dev"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl libsodium 1.0.6
elif [ ${SHORT_VERSION} == '72' ]; then
    echo "no need for building libsodium for gcp-php${SHORT_VERSION}"
    exit 0
else
    download_from_pecl libsodium
fi

build_package libsodium
