#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libsodium for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-libsodium"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl libsodium 1.0.7
elif [ ${SHORT_VERSION} == '73' ] || [ ${SHORT_VERSION} == '74' ] || [ ${SHORT_VERSION} == '80' ]; then
    echo "Sodium already builtin for gcp-php${SHORT_VERSION}"
    exit 0
else
    download_from_pecl libsodium 2.0.23
fi

build_package libsodium
