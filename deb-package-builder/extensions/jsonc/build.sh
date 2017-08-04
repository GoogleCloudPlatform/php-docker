#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

PNAME="gcp-php${SHORT_VERSION}-json"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo "Building json for gcp-php${SHORT_VERSION}"
    download_from_pecl jsonc
else
    echo "no need for building jsonc for gcp-php${SHORT_VERSION}"
    exit 0
fi

build_package jsonc
