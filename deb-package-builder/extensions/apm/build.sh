#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apm"

apt-get install -y libmysql++-dev

# Download the source
download_from_pecl APM

build_package apm
