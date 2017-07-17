#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building stackdriver trace for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-stackdriver-trace"
EXT_VERSION="0.1.0"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "PHP 5.6 is not supported"
    exit 0
fi

download_from_tarball https://github.com/GoogleCloudPlatform/stackdriver-trace-php-extension/archive/master.tar.gz ${EXT_VERSION}

build_package stackdriver_trace
