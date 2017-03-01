#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building phalcon for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-phalcon"

# Download the source
download_from_tarball https://github.com/phalcon/cphalcon/archive/v3.0.4.tar.gz 3.0.4

# Build directories are different for php 5 vs 7
if [ ${SHORT_VERSION} == "56" ]; then
  PACKAGE_DIR=${PACKAGE_DIR}/build/php5/64bits/
else
  PACKAGE_DIR=${PACKAGE_DIR}/build/php7/64bits/
fi
cp -R ${DEB_BUILDER_DIR}/extensions/phalcon/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-phalcon.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-phalcon.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
ls -l
cp ../${PNAME}_${EXT_VERSION}-${FULL_VERSION}_amd64.deb ${ARTIFACT_DIR}
popd
