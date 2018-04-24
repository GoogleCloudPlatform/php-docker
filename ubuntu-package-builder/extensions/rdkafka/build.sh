#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building rdkafka for gcp-php${SHORT_VERSION}"

apt-get install -y librdkafka-dev

PNAME="gcp-php${SHORT_VERSION}-rdkafka"

# Download the source
download_from_pecl rdkafka

build_package rdkafka
