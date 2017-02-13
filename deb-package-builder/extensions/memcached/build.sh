#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building memcached for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcached"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memcached 2.2.0
else
    download_from_pecl memcached
fi

cp -R ${DEB_BUILDER_DIR}/extensions/memcached/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-memcached.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-memcached.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
