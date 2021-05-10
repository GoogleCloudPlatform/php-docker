#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building imagick for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-imagick"
apt-get install -y fonts-urw-base35 || true
apt-get install -y libfreetype6-dev || true
apt-get install -y texlive-fonts-recommended || true

# Download the source
#download_from_pecl imagick
download_from_git https://github.com/Imagick/imagick 7.0.10-27

build_package imagick
