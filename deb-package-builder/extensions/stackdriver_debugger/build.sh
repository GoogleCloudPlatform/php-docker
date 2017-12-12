#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building stackdriver-debugger for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-stackdriver-debugger"
EXT_VERSION="0.1.0"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "PHP 5.6 is not supported"
    exit 0
fi

download_from_pecl stackdriver_debugger-devel

build_package stackdriver_debugger
