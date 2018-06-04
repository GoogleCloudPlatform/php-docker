#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building memcache for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcache"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memcache
else
    # We only build memcache for PHP 5.6.x
    exit 0
fi

build_package memcache
