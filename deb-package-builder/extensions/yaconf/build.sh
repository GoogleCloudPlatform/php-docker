#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building yaconf for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-yaconf"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo "yaconf extension only for PHP 7.0+"
    exit 0
fi

download_from_pecl yaconf

build_package yaconf
