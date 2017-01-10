#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building apcu for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apcu"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl apcu 4.0.11
else
    download_from_pecl apcu
fi

cp -R ${DEB_BUILDER_DIR}/extensions/apcu/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-apcu.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-apcu.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
