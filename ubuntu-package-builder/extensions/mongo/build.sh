#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building mongo for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-mongo"

# Download the source
if [ ${SHORT_VERSION} != '56' ]; then
    echo "deprecated mongo ext supported only on PHP 5.6"
    exit 0
else
    download_from_pecl mongo
fi

build_package mongo
