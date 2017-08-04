#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building event for gcp-php${SHORT_VERSION}"

apt-get install -y libevent-dev

PNAME="gcp-php${SHORT_VERSION}-event"

# Download the source
download_from_pecl event

build_package event
