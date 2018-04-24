#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building apm for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apm"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "apm extension only for PHP 7.0+, relies on removed json.h for PHP 5.6"
    exit 0
fi

apt-get install -y libmysql++-dev

# Download the source
download_from_pecl APM

build_package apm
