#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-xdebug"

# Download the source
download_from_pecl xdebug

build_package xdebug
