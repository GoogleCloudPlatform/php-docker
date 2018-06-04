#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building oauth for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-oauth"

# Download the source
if [ ${SHORT_VERSION} == "56" ]; then
    download_from_pecl oauth 1.2.3
else
    download_from_pecl oauth
fi

build_package oauth
