#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building zip for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-zip"

apt-get install -y libzip-dev

# Download the source
download_from_pecl zip

build_package zip
