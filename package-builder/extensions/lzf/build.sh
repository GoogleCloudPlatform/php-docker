#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building lzf for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-lzf"

# Download the source
download_from_pecl LZF

build_package lzf
