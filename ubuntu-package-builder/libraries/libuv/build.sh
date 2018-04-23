#!/bin/bash

set -ex

echo "Downloading libuv and libuv-dev from backports"

for PKG in `apt-get install --reinstall --print-uris -qq libuv1-dev | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_LIB_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_LIB_DIR}/$(basename $PKG) $PKG
  fi
done

for PKG in `apt-get install --reinstall --print-uris -qq libuv1 | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_LIB_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_LIB_DIR}/$(basename $PKG) $PKG
  fi
done
