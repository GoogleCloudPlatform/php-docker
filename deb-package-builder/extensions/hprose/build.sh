#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building hprose for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-hprose"

# Download the source
download_from_pecl hprose

build_package hprose
