#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building couchbase for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-couchbase"

curl http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-3-amd64.deb -o couchbase-release-1.0-3-amd64.deb
dpkg -i couchbase-release-1.0-3-amd64.deb

apt-get update
apt-get install -y libcouchbase-dev

# Download the source
download_from_pecl couchbase

build_package couchbase
