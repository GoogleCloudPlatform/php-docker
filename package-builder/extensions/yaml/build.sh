#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building yaml for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-yaml"

apt-get install -y libyaml-dev

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl yaml 1.3.1
else
    download_from_pecl yaml
fi

build_package yaml
