#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building libsodium for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-libsodium"

apt-get install -y \
    libsodium-dev/jessie-backports \
    libsodium18/jessie-backports

for PKG in `apt-get install --reinstall --print-uris -qq libsodium-dev | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_DIR}/$(basename $PKG) $PKG
  fi
done

for PKG in `apt-get install --reinstall --print-uris -qq libsodium18 | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_DIR}/$(basename $PKG) $PKG
  fi
done

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl libsodium 1.0.6
elif [ ${SHORT_VERSION} == '72' ]; then
    echo "no need for building libsodium for gcp-php${SHORT_VERSION}"
    exit 0
else
    download_from_pecl libsodium
fi

build_package libsodium
