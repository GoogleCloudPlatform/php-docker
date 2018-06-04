#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building apcu for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apcu"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl apcu 4.0.11
else
    download_from_pecl apcu
fi

build_package apcu
