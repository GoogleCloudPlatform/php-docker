#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-krb5"

apt-get install -y libkrb5-dev

# Download the source
download_from_pecl krb5

build_package krb5