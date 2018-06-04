#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building couchbase for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-couchbase"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "couchbase extension only for PHP 7.0+"
    exit 0
fi

curl http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-3-amd64.deb -o couchbase-release-1.0-3-amd64.deb
dpkg -i couchbase-release-1.0-3-amd64.deb

apt-get update
apt-get install -y libcouchbase-dev

# Download the source
download_from_pecl couchbase

build_package couchbase

# download libcouchbase2-core (runtime dependency)
for PKG in `apt-get download --print-uris -qq libcouchbase2-core | cut -d"'" -f2`; do
  if [ ! -f "${ARTIFACT_PKG_DIR}/$(basename $PKG)" ]; then
      curl -o ${ARTIFACT_PKG_DIR}/$(basename $PKG) $PKG
  fi
done
