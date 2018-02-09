#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building swoole for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-swoole"

# Download the source
if [ ${SHORT_VERSION} == "56" ]; then
    download_from_pecl swoole 2.0.12
else
    download_from_pecl swoole
fi

build_package swoole
