#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building igbinary for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-igbinary"

# Download the source
download_from_pecl igbinary

build_package igbinary
