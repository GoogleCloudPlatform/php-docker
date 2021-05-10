#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building opencensus for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-opencensus"

if [[ ${SHORT_VERSION} == '56' ]]; then
    echo "opencensus does not support PHP $SHORT_VERSION"
    exit 0
else
    # download_from_tarball https://github.com/census-instrumentation/opencensus-php/archive/v0.6.0.tar.gz 0.6.0
    git clone https://github.com/Timing-GmbH/opencensus-php.git

    pushd opencensus-php
    git checkout -t origin/php8-compat

    PACKAGE_DIR=`pwd`/ext
    EXT_VERSION=2.1.2

    build_package opencensus
    popd

    rm -rf opencensus-php
fi
