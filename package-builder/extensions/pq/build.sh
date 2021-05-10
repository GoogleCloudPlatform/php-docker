#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building pq for gcp-php${SHORT_VERSION}"

apt-get install -y libpq-dev

install_last_package "gcp-php${SHORT_VERSION}-raphf"
/opt/php${SHORT_VERSION}/bin/php${SHORT_VERSION}-enmod raphf

PNAME="gcp-php${SHORT_VERSION}-pq"

# Download the source
if [ ${SHORT_VERSION} == "56" ]; then
    download_from_pecl pq 1.1.1
else
    download_from_git https://github.com/m6w6/ext-pq.git 2.1.9
fi

build_package pq
