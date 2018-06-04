#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building phalcon for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-phalcon"

# Download the source
download_from_tarball https://github.com/phalcon/cphalcon/archive/v3.0.4.tar.gz 3.0.4

# Build directories are different for php 5 vs 7
if [ ${SHORT_VERSION} == "56" ]; then
    install_last_package gcp-php${SHORT_VERSION}-json
    PACKAGE_DIR=${PACKAGE_DIR}/build/php5/64bits/
elif [ ${SHORT_VERSION} == "70" ]; then
    PACKAGE_DIR=${PACKAGE_DIR}/build/php7/64bits/
else
    echo "skipping Phalcon for gcp-php${SHORT_VERSION} - not yet supported"
    exit 0
fi

build_package phalcon
