#!/bin/bash

set -ex

echo "Downloading libsodium18 and libsodium-dev from backports"

apt-get install -y \
    libsodium-dev/jessie-backports \
    libsodium18/jessie-backports

for PKG in `apt-get install --reinstall --print-uris -qq libsodium-dev | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_LIB_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_LIB_DIR}/$(basename $PKG) $PKG
  fi
done

for PKG in `apt-get install --reinstall --print-uris -qq libsodium18 | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_LIB_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_LIB_DIR}/$(basename $PKG) $PKG
  fi
done
