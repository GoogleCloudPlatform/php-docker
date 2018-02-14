#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building mongo for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-mongo"

# Download the source
if [ ${SHORT_VERSION} == '70' ] || [ ${SHORT_VERSION} == '71' ]; then
    echo "deprecated mongo ext doesn't support PHP 7.x"
    exit 0
else
    download_from_pecl mongo
fi

build_package mongo
