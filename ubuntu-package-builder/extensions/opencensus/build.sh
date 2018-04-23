#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building opencensus for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-opencensus"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "opencensus doesn't support PHP 5.6"
    exit 0
else
    download_from_pecl opencensus-alpha
fi

build_package opencensus
