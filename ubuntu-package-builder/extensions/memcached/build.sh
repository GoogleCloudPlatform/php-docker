#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building memcached for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcached"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memcached 2.2.0
else
    download_from_pecl memcached
fi

build_package memcached
