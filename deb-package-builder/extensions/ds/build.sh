#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-ds"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "ds extension only for PHP 7.0+"
    exit 0
fi

# Download the source
download_from_pecl ds

build_package ds
