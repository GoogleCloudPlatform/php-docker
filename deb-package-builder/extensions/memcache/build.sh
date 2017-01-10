#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building memcache for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcache"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memcache
else
    # We only build memcache for PHP 5.6.x
    exit 0
fi

cp -R ${DEB_BUILDER_DIR}/extensions/memcache/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-memcache.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-memcache.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
