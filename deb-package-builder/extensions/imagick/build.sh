#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building imagick for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-imagick"

# Download the source
download_from_pecl imagick

build_package imagick
