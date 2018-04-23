#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

apt-get install -y libev-dev

PNAME="gcp-php${SHORT_VERSION}-ev"

# Download the source
download_from_pecl ev

build_package ev
