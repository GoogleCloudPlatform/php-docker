#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building swoole for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-swoole"

# Download the source
download_from_pecl swoole

build_package swoole
