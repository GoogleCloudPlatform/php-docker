#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building bitset for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-bitset"

# Download the source
if [ ${SHORT_VERSION} == "56" ]; then
    download_from_pecl bitset 2.0.4
else
    download_from_pecl bitset
fi

build_package bitset
