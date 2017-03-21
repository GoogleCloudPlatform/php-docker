#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building cassandra for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-cassandra"

ls -t ${ARTIFACT_DIR}/libuv1_* | head -n 1 | xargs dpkg -i
ls -t ${ARTIFACT_DIR}/libuv1-dev_* | head -n 1 | xargs dpkg -i
ls -t ${ARTIFACT_DIR}/cassandra-cpp-driver_* | head -n 1 | xargs dpkg -i
ls -t ${ARTIFACT_DIR}/cassandra-cpp-driver-dev_* | head -n 1 | xargs dpkg -i
apt-get install -y libgmp-dev

# Download the source
download_from_pecl cassandra

build_package cassandra
